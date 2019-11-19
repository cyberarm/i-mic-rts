class IMICRTS
  class Networking
    module Protocol
      VERSION = 0x01
      END_OF_MESSAGE = "\r\r\r\n"

      ACKNOWLEDGE = 0x01
      CONNECT = 0x02
      VERIFY_CONNECT = 0x03
      DISCONNECT = 0x04
      PING = 0x05

      RELIABLE = 0x20
      UNRELIABLE = 0x21
      UNSEQUENCED = 0x22
      FRAGMENT = 0x23
      UNRELIABLE_FRAGMENT = 0x24

      BANDWIDTH_LIMIT = 0x40
      THROTTLE_CONFIGURE = 0x41
      COUNT = 0x42
      MASK = 0x43

      HEADER_FLAG_COMPRESSED = 0x00
      HEADER_FLAG_SENT_TIME = 0x01

      def self.max_packet_length
        1024 # => 1 Kb
      end
    end
  end
end