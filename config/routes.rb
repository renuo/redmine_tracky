# frozen_string_literal: true

# Plugin's routes
# See: http://guides.rubyonrails.org/routing.htm
resources :timer_sessions, only: %i[index edit update patch destroy]

post 'time_tracker/start', to: 'time_tracker#start', as: :start_time_tracker
post 'time_tracker/stop', to: 'time_tracker#stop', as: :stop_time_tracker
post 'time_tracker/update', to: 'time_tracker#update', as: :update_time_tracker
