class UndefinedMiddlewareError < StandardError
  def initialize
    super('call method is not defined!')
  end
end
