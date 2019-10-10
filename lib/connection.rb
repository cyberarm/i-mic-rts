class IMICRTS
  class Connection
    def initialize(*args)
      @pending_orders = []
    end

    def add_order(order)
      @pending_orders.push(order)
    end

    def update
      data = @pending_orders.sort_by { |order| order.tick_id }.map do |order|

        # Order serialized size in bytes + serialized order data
        [order.serialized_order.length].pack("n") + order.serialized_order
      end.join

      # p data if data.length > 0

      @pending_orders.clear
    end
  end
end