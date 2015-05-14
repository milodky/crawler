require 'mechanize'
class WeiboLogin < Crawler::Middleware

  LOGIN_URL = 'http://login.weibo.cn/login/?backURL=http%3A%2F%2Fweibo.cn%2F&backTitle=%E5%BE%AE%E5%8D%9A&vt=1&revalid=2&ns=1&pt=1'
  LOGIN_URL = 'http://login.weibo.cn/login/?rand=1103689512&backURL=http%3A%2F%2Fweibo.cn%2F&backTitle=%E5%BE%AE%E5%8D%9A&vt=1&revalid=2&ns=1'

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
    env[:page] = try_login(agent)
  end

  ###############################################################
  # try to login to weibo phone version
  #
  def try_login(agent)
    agent.user_agent_alias = 'Mac Safari'
    page = agent.get(LOGIN_URL)
    form = page.forms[0]
    form.field_with(:name => /mobile/i).value   = @username
    form.field_with(:name => /password/i).value = @password
    form.click_button
  end
end
