class Crawler
  def configuration(params = nil, &block)
    raise ArgumentError.new('The first argument should be nil a hash!') unless params.is_a?(Hash) || params.nil?
    if block_given?
      block.call(self)
    end
  end

  def register(middle_ware, params = {})
    @middle_wares << middle_ware.new(params)
  end
end