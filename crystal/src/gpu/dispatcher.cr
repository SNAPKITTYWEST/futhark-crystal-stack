require "../protocol/frame"

module Stack
  module GPU
    # Dispatch layer. In production this loads Futhark-generated shared
    # libraries via C ABI. Here we provide a pure-Crystal reference
    # implementation of the mathematical contracts so the whole stack
    # runs without a GPU.

    class Dispatcher
      def self.dispatch(req : Protocol::Request) : Bytes
        case req.opcode
        when Protocol::Opcode::Compute, Protocol::Opcode::Batch
          if req.body.empty?
            return error_reply(req.request_id, Protocol::Status::BadFrame)
          end

          # Interpret body as packed f32 array and return its sum.
          n = req.body.size // 4
          sum = 0.0_f32
          n.times do |i|
            sum += IO::ByteFormat::LittleEndian.decode(Float32, req.body[i*4, 4])
          end

          out_payload = Bytes.new(4)
          IO::ByteFormat::LittleEndian.encode(sum, out_payload)

          resp = Protocol::Response.new(req.request_id, Protocol::Status::Ok,
                                        1_u16, out_payload)
          io = IO::Memory.new
          Protocol::FrameCodec.write_response(io, resp)
          io.to_slice
        else
          error_reply(req.request_id, Protocol::Status::BadOpcode)
        end
      end

      private def self.error_reply(id : UInt64, st : Protocol::Status) : Bytes
        resp = Protocol::Response.new(id, st)
        io = IO::Memory.new
        Protocol::FrameCodec.write_response(io, resp)
        io.to_slice
      end
    end

    # Memory ownership tracker (host → pinned → device).
    class Buffer
      enum Location
        Host
        Pinned
        Device
      end

      property id : UInt64
      property size : Int64
      property location : Location
      property shape : Array(Int64)
      property owner_req : UInt64

      def initialize(@id, @size, @location, @shape, @owner_req)
      end
    end

    class MemoryTracker
      def initialize
        @buffers = {} of UInt64 => Buffer
        @next_id = Atomic(UInt64).new(1_u64)
      end

      def allocate(size : Int64, shape : Array(Int64),
                   loc : Buffer::Location, req : UInt64) : UInt64
        id = @next_id.add(1)
        @buffers[id] = Buffer.new(id, size, loc, shape, req)
        id
      end

      def free(id : UInt64)
        @buffers.delete(id)
      end

      def get(id : UInt64) : Buffer?
        @buffers[id]?
      end
    end
  end
end
