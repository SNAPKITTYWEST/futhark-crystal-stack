require "../crystal/src/protocol/frame"

data = Bytes.new(16)
[1.0_f32, 2.0_f32, 3.0_f32, 4.0_f32].each_with_index do |v, i|
  IO::ByteFormat::LittleEndian.encode(v, data[i*4, 4])
end

req = Stack::Protocol::Request.new(99_u64, Stack::Protocol::Opcode::Compute,
                                   0_u8, 1_u16, data)

io = IO::Memory.new
Stack::Protocol::FrameCodec.write_request(io, req)
io.rewind
decoded = Stack::Protocol::FrameCodec.read_request(io)

raise "id mismatch" unless decoded.request_id == 99
raise "opcode mismatch" unless decoded.opcode == Stack::Protocol::Opcode::Compute
raise "body mismatch" unless decoded.body == data

puts "protocol round-trip OK"
