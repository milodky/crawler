require 'mechanize'
require 'timeout'
require "#{File.dirname(__FILE__)}/errors/errors"
require "#{File.dirname(__FILE__)}/configuration"
require "#{File.dirname(__FILE__)}/middleware/crawler_middleware"
require 'active_support/all'
require '../middlewares/weibo_login'
class Crawler
  DEFAULT_DEPTH = 2
  TIMEOUT       = 0.5

  def initialize(params)
    raise ArgumentError.new('The input must be a hash!') unless params.is_a?Hash
    @params = params.dup.with_indifferent_access
    @middle_wares = []
    @agent  = Mechanize.new
    @params[:agent] = @agent unless @params[:agent]
  end

  def method_missing(method, *args)
    case method 
      when /.*=/
        key, _       = method.to_s.split('=')
        @params[key] = args[0]
      else @params[method]
    end
  end

  def start_crawling
    if url
      page = @agent.get(url)
    else
      @middle_wares.each do |mw|
        mw.call(@params)
      end
      page = @params[:page]
    end

    process(page, 0)
  end

  def process(page, depth)
    return if page.nil? || depth >= (crawling_depth || DEFAULT_DEPTH)
    page.links.each do |link|
      begin
        sub_page   = nil
        Timeout.timeout(TIMEOUT, TimeoutError) do
          sub_page = link.click
        end
        process(sub_page, depth + 1)
        sleep(0.2)
      rescue Mechanize::UnsupportedSchemeError => _
        $stderr.puts 'Error: Found link with unsupported scheme, trying another'
      rescue Mechanize::ResponseCodeError => err
        $stderr.puts "Error: #{err.message}"
      rescue TimeoutError => err
        $stderr.puts "Error: Timeout(#{err.message})"
      end


    end
    log(page)
  end

  ###############################################################
  # to log what we want
  # can be overwritten by other classes
  # Input:
  #   - page: a Machanize page object
  def log(page)
    return if page.nil?
    # for now let's do image
    page.images.each do |image|
      next unless image.extname =~ /jpg/
      sleep(0.2)
      src = image.attributes['src']
      @agent.get(src).save_as("#{rand(100000)}.jpg")
puts 'succeeded!'
    end
  end
end

if __FILE__ == $0
  case ARGV.size
    when 2, 3
      username = ARGV[0]
      password = ARGV[1]
      depth    = ARGV[2]
    else
      raise ArgumentError.new('The size of arguments should either be 1 or 2')
  end
  crawler = Crawler.new(:crawling_depth => depth)
  crawler.configuration do |cr|
    cr.register WeiboLogin, :username => username, :password => password
  end

  crawler.start_crawling
end