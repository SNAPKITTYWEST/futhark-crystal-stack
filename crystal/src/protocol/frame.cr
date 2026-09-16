require "./opcodes"
require "./checksum"

module Stack
  module Protocol
    # Request frame layout (little-endian):
    # MAGIC u32 | VERSION u16 | REQUEST_ID u64 | OPCODE u8 | FLAGS u8
    # INPUT_COUNT u16 | BODY_LEN u32 | BODY bytes | CHECKSUM u32

    struct Request
      getter magic : UInt32
      getter version : UInt16
      getter request_id : UInt64
      getter opcode : Opcode
      getter flags : UInt8
      getter input_count : UInt16
      getter body : Bytes
      getter checksum : UInt32

      def initialize(@request_id : UInt64, @opcode : Opcode,
                     @flags : UInt8 = 0_u8,
                     @input_count : UInt16 = 0_u16,
                     @body : Bytes = Bytes.empty)
        @magic = MAGIC
        @version = VERSION
        @checksum = Checksum.compute(@body)
      end
    end

    struct Response
      getter magic : UInt32
      getter version : UInt16
      getter request_id : UInt64
      getter status : Status
      getter output_count : UInt16
      getter body : Bytes
      getter checksum : UInt32

      def initialize(@request_id : UInt64, @status : Status,
                     @output_count : UInt16 = 0_u16,
                     @body : Bytes = Bytes.empty)
        @magic = MAGIC
        @version = VERSION
        @checksum = Checksum.compute(@body)
      end
    end

    module FrameCodec
      HEADER_SIZE = 4 + 2 + 8 + 1 + 1 + 2 + 4 # 22 bytes
      FOOTER_SIZE = 4

      def self.write_request(io : IO, req : Request)
        io.write_bytes(req.magic, IO::ByteFormat::LittleEndian)
        io.write_bytes(req.version, IO::ByteFormat::LittleEndian)
        io.write_bytes(req.request_id, IO::ByteFormat::LittleEndian)
        io.write_byte(req.opcode.value)
        io.write_byte(req.flags)
        io.write_bytes(req.input_count, IO::ByteFormat::LittleEndian)
        io.write_bytes(req.body.size.to_u32, IO::ByteFormat::LittleEndian)
        io.write(req.body)
        io.write_bytes(req.checksum, IO::ByteFormat::LittleEndian)
        io.flush
      end

      def self.read_request(io : IO) : Request
        buf = Bytes.new(HEADER_SIZE)
        io.read_fully(buf)

        magic      = IO::ByteFormat::LittleEndian.decode(UInt32, buf[0, 4])
        version    = IO::ByteFormat::LittleEndian.decode(UInt16, buf[4, 2])
        request_id = IO::ByteFormat::LittleEndian.decode(UInt64, buf[6, 8])
        opcode_byte = buf[14]
        flags      = buf[15]
        input_count = IO::ByteFormat::LittleEndian.decode(UInt16, buf[16, 2])
        body_len   = IO::ByteFormat::LittleEndian.decode(UInt32, buf[18, 4])

        raise "bad magic" unless magic == MAGIC
        raise "version mismatch" unless version == VERSION
        raise "payload too large" if body_len > MAX_PAYLOAD

        body = Bytes.new(body_len)
        io.read_fully(body) unless body_len == 0

        cksum_buf = Bytes.new(4)
        io.read_fully(cksum_buf)
        checksum = IO::ByteFormat::LittleEndian.decode(UInt32, cksum_buf)

        raise "checksum mismatch" unless Checksum.compute(body) == checksum

        opcode = Opcode.new(opcode_byte)
        Request.new(request_id, opcode, flags, input_count, body)
      end

      def self.write_response(io : IO, resp : Response)
        io.write_bytes(resp.magic, IO::ByteFormat::LittleEndian)
        io.write_bytes(resp.version, IO::ByteFormat::LittleEndian)
        io.write_bytes(resp.request_id, IO::ByteFormat::LittleEndian)
        io.write_byte(resp.status.value)
        io.write_bytes(resp.output_count, IO::ByteFormat::LittleEndian)
        io.write_bytes(resp.body.size.to_u32, IO::ByteFormat::LittleEndian)
        io.write(resp.body)
        io.write_bytes(resp.checksum, IO::ByteFormat::LittleEndian)
        io.flush
      end
    end
  end
end
