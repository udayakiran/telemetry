Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resource :heartbeat, controller: 'heartbeat'
  resource :server, controller: 'server', only: [:show]
  resource :client, controller: 'client', only: [:show]
  
  root "client#show"
end
