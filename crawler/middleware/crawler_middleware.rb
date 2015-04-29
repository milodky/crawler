class Crawler::Middleware
  def call(env)
    raise UndefinedMiddlewareError.new
  end
end

class UndefinedMiddlewareError < StandardError
  def initialize
    super('call method is not defined!)
  end
end
