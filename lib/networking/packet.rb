class IMICRTS
  class Networking
    class Packet
      # Packet
      # [
      #   header_packet_type,
      #   header_packet_length,
      #   header_packet_sequence_id,
      #   header_packet_client_id,
      #
      #   data
      # ]
      attr_reader :type, :sequence_id, :client_id, :data
      def initialize(type:, sequence_id: nil, client_id:, data:)
        @type = type
        @sequence_id = sequence_id
        @client_id = client_id
        @data = data
      end

      def self.pack(packet)
        header = nil

        # Packet Type: Char => "C"
        # Packet Sequence ID: 32-bit unsigned Integer => "N"
        # Packet Client ID: 16-bit unsigned Integer => "n"

        if packet.sequence_id
          header = [packet.type, packet.sequence_id, packet.client_id].pack("CNn")
        else
          header = [packet.type, packet.client_id].pack("Cn")
        end

        header += packet.data
      end

      def self.unpack(raw_string)
        pp raw_string.unpack("Cn")
      end
    end
  end
end