require 'mechanize'

class WeiboLogin < CrawlerMiddleware

  LOGIN_URL = ''

  # not sure what should be passed here
  def initialize(params)
    @username = params[:username]
    @password = params[:password]
  end

  # must have this method
  # basically overwrite the original one
  # no callback currently
  def call(env)
    login(env)
  end

  def login(env)
    agent = env['agent']
    # agent must be there!
    raise ArgumentError.new('cannot find the mechanize agent!') if agent.nil?
    # try_login, write the url back to env
    env[:url] = try_login(agent)
  end

  ###############################################################
  # try to login to weibo phone version
  #
  def try_login(agent)
    page = agent.get(LOGIN_URL)
    form = login_page.forms[1]
    # need to figure out the fields
    form.submit
  ends
end
