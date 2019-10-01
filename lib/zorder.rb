class IMICRTS
  class ZOrder
    base_z = 5
    enum = [
      :GROUND_VEHICLE
    ]

    enum.each_with_index do |constant, index|
      self.const_set(constant, index + base_z)
    end
  end
end