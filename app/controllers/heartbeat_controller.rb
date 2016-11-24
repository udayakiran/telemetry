class HeartbeatController < ApplicationController
  
  def create
    HeartbeatMonitor.new(params).save
    head :ok
  end
  
  def show
    @hb = HeartbeatMonitor.new(params)
    @hb_stream = @hb.get_stream
    @client_info = @hb.store.hmget(@hb.client.uid,"gen_func", "min_critical", "max_critical")
  end
  
end
