require 'redis'
require 'multi_json'

class PubSubRedis < Redis

  def initialize(options = {})
    @timestamp = options[:timestamp].to_i || 0 # 0 means -- no backlog needed
    super
  end

  # Add each event to a Sorted Set with the timestamp as the score
  def publish(channel, message)
    super(channel, MultiJson.encode(message))
  end
end
