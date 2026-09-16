require "socket"
require "../router/router"
require "../scheduler/queue"

module Stack
  module Runtime
    class Server
      def initialize(@host : String = "0.0.0.0", @port : Int32 = 9090,
                     workers : Int32 = 4, queue_cap : Int32 = 128)
        @queue = Scheduler::JobQueue.new(queue_cap, workers)
        @router = Router::EventRouter.new(@queue)
        @running = true
      end

      def start
        server = TCPServer.new(@host, @port)
        puts "fc-stack listening on #{@host}:#{@port} (Python-free)"

        while @running
          socket = server.accept?
          break unless socket
          spawn do
            @router.handle_connection(socket)
          end
        end
      ensure
        @queue.close
        server.try &.close
      end

      def stop
        @running = false
      end
    end
  end
end
