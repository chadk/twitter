module Twitter
  class Trends
    extend SingleForwardable

    def initialize(options={})
      @adapter = options.delete(:adapter)
      @api_endpoint = "api.twitter.com/#{Twitter.api_version}/trends"
      @api_endpoint = Addressable::URI.heuristic_parse(@api_endpoint)
      @api_endpoint = @api_endpoint.to_s
    end

    # :exclude => 'hashtags' to exclude hashtags
    def current(options={})
      results = connection.get do |request|
        request.url "current.#{Twitter.format}", options
      end.body
    end

    # :exclude => 'hashtags' to exclude hashtags
    # :date => yyyy-mm-dd for specific date
    def daily(options={})
      results = connection.get do |request|
        request.url "daily.#{Twitter.format}", options
      end.body
    end

    # :exclude => 'hashtags' to exclude hashtags
    # :date => yyyy-mm-dd for specific date
    def weekly(options={})
      results = connection.get do |request|
        request.url "weekly.#{Twitter.format}", options
      end.body
    end

    def available(options={})
      connection.get do |request|
        request.url "available.#{Twitter.format}", options
      end.body
    end

    def for_location(woeid, options = {})
      connection.get do |request|
        request.url "#{woeid}.#{Twitter.format}", options
      end.body
    end

    def self.client; self.new end

    def_delegators :client, :current, :daily, :weekly, :available, :for_location

    private

    def connection
      headers = {:user_agent => Twitter.user_agent}
      ssl = {:verify => false}
      @connection = Faraday::Connection.new(:url => @api_endpoint, :headers => headers, :ssl => ssl) do |builder|
        builder.adapter(@adapter || Faraday.default_adapter)
        case Twitter.format.to_s
        when "json"
          builder.use Faraday::Response::ParseJson
        when "xml"
          builder.use Faraday::Response::ParseXml
        end
        builder.use Faraday::Response::RaiseErrors
        builder.use Faraday::Response::Mashify
      end
      @connection.scheme = Twitter.scheme
      @connection
    end

  end
end
