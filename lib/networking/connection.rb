class IMICRTS
  class Networking
    class Connection
      def initialize(director:, hostname:, port:)
        @director = director
        @hostname = hostname
        @port = port

        @client = Networking::Client.new(TCPSocket.new(@hostname, @port))
      end

      def connected?
        @client.connected?
      end

      def update
        @client.update
      end

      def close
        @client.close
      end
    end
  end
end