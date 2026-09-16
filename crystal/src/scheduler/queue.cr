require "../protocol/frame"

module Stack
  module Scheduler
    class Job
      getter request : Protocol::Request
      getter on_complete : Bytes -> Nil

      def initialize(@request : Protocol::Request, &@on_complete : Bytes -> Nil)
      end
    end

    # Bounded job queue using Crystal Channel (async, non-blocking).
    class JobQueue
      def initialize(@capacity : Int32 = 128, workers : Int32 = 4)
        @ch = Channel(Job).new(@capacity)
        @closed = false
        workers.times do
          spawn { worker_loop }
        end
      end

      def enqueue(job : Job) : Bool
        return false if @closed
        select
        when @ch.send(job)
          true
        else
          false
        end
      end

      def close
        @closed = true
        @ch.close
      end

      private def worker_loop
        loop do
          job = @ch.receive?
          break unless job

          begin
            result = GPU::Dispatcher.dispatch(job.request)
            job.on_complete.call(result)
          rescue ex
            resp = Protocol::Response.new(job.request.request_id, Protocol::Status::GpuError)
            io = IO::Memory.new
            Protocol::FrameCodec.write_response(io, resp)
            job.on_complete.call(io.to_slice)
            STDERR.puts "worker error: #{ex.message}"
          end
        end
      end
    end
  end
end
