class ServerController < ApplicationController
  
  def show
    @heartbeat_keys = HeartbeatMonitor.new({}).get_hb_keys
  end
  
end
