require "socket"
require "../crystal/src/protocol/frame"
require "../crystal/src/net/framing"

host = ARGV[0]? || "127.0.0.1"
port = (ARGV[1]? || "9090").to_i

socket = TCPSocket.new(host, port)
frame_io = Stack::Net::FrameIO.new(socket)

# Build a simple f32 vector [1.0, 2.0, 3.0, 4.0]
data = Bytes.new(16)
[1.0_f32, 2.0_f32, 3.0_f32, 4.0_f32].each_with_index do |v, i|
  IO::ByteFormat::LittleEndian.encode(v, data[i*4, 4])
end

req = Stack::Protocol::Request.new(42_u64, Stack::Protocol::Opcode::Compute,
                                   0_u8, 1_u16, data)
io = IO::Memory.new
Stack::Protocol::FrameCodec.write_request(io, req)
frame_io.write_frame(io.to_slice)
puts "sent compute request id=42"

raw = frame_io.read_frame
resp_io = IO::Memory.new(raw)
magic   = resp_io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
version = resp_io.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
rid     = resp_io.read_bytes(UInt64, IO::ByteFormat::LittleEndian)
status  = resp_io.read_bytes(UInt8)

puts "response: magic=0x#{magic.to_s(16)} ver=#{version} id=#{rid} status=#{status}"
socket.close
puts "done"
