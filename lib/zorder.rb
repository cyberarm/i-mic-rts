class IMICRTS
  class ZOrder
    base_z = 5
    enum = [
      :TILE,
      :ORE,
      :DECORATION,
      :GROUND_VEHICLE,
      :BUILDING,
      :AIR_VEHICLE,

      :ENTITY_RADIUS,
      :ENTITY_GIZMOS, # Health bar and the like

      :OVERLAY,
      :SELECTION_BOX,
    ]

    enum.each_with_index do |constant, index|
      self.const_set(constant, index + base_z)
    end
  end
end