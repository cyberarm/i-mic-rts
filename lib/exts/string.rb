class String
  def to_snakecase
    self.to_s.split("::").last.gsub(/([^A-Z])([A-Z]+)/,'\1_\2').downcase.to_sym
  end
end