class IMICRTS
  # {IMICRTS::Connection} is the abstract middleman that Director sends/receives Orders from.
  # not to be confused with {IMICRTS::Networking::Connection}
  class Connection
    # Connection modes:
    #   :virtual => emulates networking without sockets (used for solo play)
    #   :host => starts server
    #   :client => connects to server/host
    def initialize(director:, mode:, hostname: "localhost", port: 56789)
      @director = director
      @mode = mode
      @hostname = hostname
      @port = port

      @pending_orders = []

      case @mode
      when :virtual
      when :host
        @server = Networking::Server.new(director: @director, hostname: @hostname, port: @port)

        @connection = Networking::Connection.new(director: @director, hostname: @hostname, port: @port)
      when :client
        @connection = Networking::Connection.new(director: @director, hostname: @hostname, port: @port)
      else
        raise RuntimeError, "Unable to process Connection of type: #{@mode.inspect}"
      end
    end

    def add_order(order)
      @pending_orders.push(order)
    end

    def update
      # data = @pending_orders.sort_by { |order| order.tick_id }.map do |order|

      #   # Order serialized size in bytes + serialized order data
      #   pp order.serialized_order
      #   [order.serialized_order.length].pack("n") + order.serialized_order
      # end.join

      if @mode == :virtual
      else
        @pending_orders.each do |order|
          # TODO: make this include order_id and tick_id
          @server.broadcast(order.serialized_order) if @server
          @connection.write(order.serialized_order) unless @server

          @pending_orders.delete(order)
        end
      end

      case @mode
      when :virtual
      when :host
        @server.update
        @connection.update
      when :client
        @connection.update
      end
    end

    def finalize
      @server.stop if @server
      @connection.close if @connection
    end
  end
end