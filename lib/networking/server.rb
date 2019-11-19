class IMICRTS
  class Networking
    class Server
      def initialize(director:, hostname:, port:, max_peers: 8)
        @director = director
        @hostname, @port = hostname, port
        @max_peers = max_peers

        @socket = TCPServer.new(hostname, port)
        @clients = []
      end

      def update
        new_client = @socket.accept_nonblock(exception: false)

        if new_client != :wait_readable
          handle_client(new_client)
        end

        @clients.each do |client|
          client.update
        end
      end

      def handle_client(client)
        if @clients.size < @max_peers
          @clients << Networking::Client.new(client)
        else
          client.write("\u00000128")
          client.close
        end
      end

      def broadcast(packet)
        @clients.each do |client|
          client.write(packet)
        end
      end

      def write(client_id, packet)
        client = @clients.find { |cl| cl.uid == client_id }

        client.write(packet) if client
      end

      def stop
        @socket.close if @socket
      end
    end
  end
end