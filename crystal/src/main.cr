require "./runtime/server"

host = "0.0.0.0"
port = 9090

ARGV.each_with_index do |arg, i|
  case arg
  when "--host"
    host = ARGV[i + 1]? || host
  when "--port"
    port = (ARGV[i + 1]? || "9090").to_i
  when "--help", "-h"
    puts "Usage: fc-stack [--host HOST] [--port PORT]"
    exit 0
  end
end

server = Stack::Runtime::Server.new(host, port)
server.start
