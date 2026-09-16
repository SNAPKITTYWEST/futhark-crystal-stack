require "../protocol/frame"

module Stack
  module Net
    # Length-prefixed framing (4-byte little-endian length + payload).
    # Bounded, deterministic, no dynamic JSON.

    class FrameIO
      def initialize(@io : IO, @max_frame : Int32 = Stack::Protocol::MAX_PAYLOAD + 4096)
      end

      def write_frame(payload : Bytes)
        raise "frame too large" if payload.size > @max_frame
        len_buf = Bytes.new(4)
        IO::ByteFormat::LittleEndian.encode(payload.size.to_u32, len_buf)
        @io.write(len_buf)
        @io.write(payload)
        @io.flush
      end

      # Blocking read of one complete frame. Raises on disconnect / oversized.
      def read_frame : Bytes
        len_buf = Bytes.new(4)
        @io.read_fully(len_buf)
        len = IO::ByteFormat::LittleEndian.decode(UInt32, len_buf).to_i32
        raise "oversized frame #{len}" if len < 0 || len > @max_frame
        payload = Bytes.new(len)
        @io.read_fully(payload)
        payload
      end
    end
  end
end
