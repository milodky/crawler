class Crawler::Middleware
  def call(env)
    raise UndefinedMiddlewareError.new
  end
end

