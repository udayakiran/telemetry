class Client
  
  CHANNEL_PREFIX = "tele_"
  attr_accessor :uid
  
  def initialize(id)
    @uid = id
  end
  
  def channel
    CHANNEL_PREFIX + uid
  end
end
