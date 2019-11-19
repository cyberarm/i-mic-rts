class IMICRTS
  class Networking
    class Client
      attr_reader :packets_sent, :packets_received,
                  :data_sent, :data_received
      def initialize(socket)
        @socket = socket

        @packets_sent, @packets_received = 0, 0
        @data_sent, @data_received = 0, 0

        @read_queue = []
        @write_queue = []
      end

      def update
        if connected?
          buffer = @socket.recv_nonblock(Networking::Protocol.max_packet_length, exception: false)

          if buffer.is_a?(String)
            order = buffer.split(Protocol::END_OF_MESSAGE).first.strip
          end

          until(@write_queue.size == 0)
            packet = @write_queue.shift

            @socket.write_nonblock(packet + Protocol::END_OF_MESSAGE, exception: false)
          end
        end
      end

      def connected?
        !@socket.closed?
      end

      def close(packet = nil)
        @socket.write(Networking::Packet.pack(packet) + Protocol::END_OF_MESSAGE) if packet

        @socket.close
      end

      def write(data)
        packet = Networking::Packet.new(type: Protocol::RELIABLE, client_id: 0, data: data)
        @write_queue << Networking::Packet.pack(packet)
      end

      def read
        return @read_queue.shift
      end
    end
  end
end