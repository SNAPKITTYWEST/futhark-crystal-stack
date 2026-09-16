require "../protocol/frame"
require "../net/framing"
require "../scheduler/queue"

module Stack
  module Router
    # Asynchronous event router with explicit backpressure.
    # TCP connection → frame decode → opcode dispatch → job scheduler

    class EventRouter
      def initialize(@queue : Scheduler::JobQueue, @max_inflight : Int32 = 64)
        @inflight = Atomic(Int32).new(0)
      end

      def handle_connection(socket : TCPSocket)
        frame_io = Net::FrameIO.new(socket)
        loop do
          begin
            raw = frame_io.read_frame
            req = Protocol::FrameCodec.read_request(IO::Memory.new(raw))

            if @inflight.get >= @max_inflight
              reply = error_response(req.request_id, Protocol::Status::QueueFull)
              frame_io.write_frame(reply)
              next
            end

            case req.opcode
            when Protocol::Opcode::Compute, Protocol::Opcode::Batch
              @inflight.add(1)
              job = Scheduler::Job.new(req) do |result|
                @inflight.sub(1)
                begin
                  frame_io.write_frame(result)
                rescue
                  # client gone
                end
              end
              unless @queue.enqueue(job)
                @inflight.sub(1)
                reply = error_response(req.request_id, Protocol::Status::QueueFull)
                frame_io.write_frame(reply)
              end

            when Protocol::Opcode::Status
              resp = Protocol::Response.new(req.request_id, Protocol::Status::Ok)
              io = IO::Memory.new
              Protocol::FrameCodec.write_response(io, resp)
              frame_io.write_frame(io.to_slice)

            when Protocol::Opcode::Shutdown
              resp = Protocol::Response.new(req.request_id, Protocol::Status::Ok)
              io = IO::Memory.new
              Protocol::FrameCodec.write_response(io, resp)
              frame_io.write_frame(io.to_slice)
              break

            else
              reply = error_response(req.request_id, Protocol::Status::BadOpcode)
              frame_io.write_frame(reply)
            end
          rescue ex : Exception
            STDERR.puts "router error: #{ex.message}"
            break
          end
        end
      ensure
        socket.close rescue nil
      end

      private def error_response(id : UInt64, st : Protocol::Status) : Bytes
        resp = Protocol::Response.new(id, st)
        io = IO::Memory.new
        Protocol::FrameCodec.write_response(io, resp)
        io.to_slice
      end
    end
  end
end
