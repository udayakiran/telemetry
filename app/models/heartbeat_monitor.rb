class HeartbeatMonitor
  
  MIN_CRITICAL = 0
  MAX_CRITICAL = 10
  
  INCREMENT_GEN_FUNC = "increment by X"
  DECREMENT_GEN_FUNC = "decrement by X"
  
  attr_accessor :client, :payload, :payload_too_small, :payload_too_big, :store
  
  def initialize(args)
    @client = Client.new(args[:client_uid])
    @payload = args[:payload].to_i
    @store ||= PubSubRedis.connect
  end
  
  def save
    create_client_info if store.hget(@client.uid, "gen_func").blank?
    critical_limits_exceeded? ? send_limit_generation_function :  save_heartbeat
  end
    
  #Redis Hash with key - client id, Fields - gen_func, min_critical, max_critical
  def create_client_info
    store.hmset(@client.uid, "gen_func", "increment by 1", "min_critical", MIN_CRITICAL, "max_critical", MAX_CRITICAL )
  end
  
  #Redis sorted sets with key - hb:<client id>, timestamp int for order key and json data with time and payload as value.
  def save_heartbeat
    timestamp = Time.now.to_i
    store.zadd("hb:#{@client.uid}", timestamp, [Time.now.to_s(:db), @payload].to_json)
  end
  
  def critical_limits_exceeded?
    min = store.hget(@client.uid, "min_critical").to_i
    max = store.hget(@client.uid, "max_critical").to_i
    @payload_too_small = min > @payload
    @payload_too_big = max < @payload
    @payload_too_small || @payload_too_big
  end
  
  def send_limit_generation_function
    gen_func = @payload_too_small ? "increment by 1" : "decrement by 1"
    send_generation_function(gen_func)
  end
  
  def send_generation_function(gen_func)
    store.hmset(@client.uid, "gen_func", gen_func)
    
    Juggernaut.publish(@client.channel, {:generation_function => gen_func})   
  end
  
  def send_critical_limits(min, max)
    raise "Min shoulb be smaller than max" if min >= max
    store.hmset(@client.uid, "min_critical", min, "max_critical", max)
    
    Juggernaut.publish(@client.channel, {:critical_limits => [min, max]})
  end
  
  def get_stream
    hb_stream = store.zrangebyscore "hb:#{client.uid}", "(-inf", "+inf"
    hb_stream.collect { |i| JSON.parse(i) }
  end
  
  def get_hb_keys
    store.keys "hb:*"
  end
end
