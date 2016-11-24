require "redis"
require "json"
require "pub_sub_redis"

# Attempt to provide Engine to Rails
require "juggernaut/rails/engine"

module Juggernaut
  EVENTS = [
    "juggernaut:subscribe", 
    "juggernaut:unsubscribe", 
    "juggernaut:custom"
  ]
  
  def options
    @options ||= {}
  end
  
  def options=(val)
    @options = val
  end
  
  def url=(url)
    options[:url] = url
  end
  
  def publish(channels, data, options = {})
    message = ({:channels => Array(channels).uniq, :data => data}).merge(options)
    redis.publish(key, message)
  end
  
  def subscribe
    PubSubRedis.connect(options).subscribe(*EVENTS) do |on|
      on.message do |type, msg|
        yield(type.gsub(/^juggernaut:/, "").to_sym, JSON.parse(msg))
      end
    end
  end
  
  protected
    def redis
      @redis ||= PubSubRedis.connect(options)
    end
  
    def key(*args)
      args.unshift(:juggernaut).join(":")
    end

    extend self
end
