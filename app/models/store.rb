class Store < PubSubRedis
  attr_accessor :redis_connection
  
  def initialize
    @redis_connection ||= PubSubRedis.connect
    @redis_connection
  end
end
