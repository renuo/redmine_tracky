# frozen_string_literal: true

# Plugin's routes
# See: http://guides.rubyonrails.org/routing.htm
get 'end_to_end_testing_helper', to: 'end_to_end_testing#index'

get 'timer_sessions', to: 'timer_sessions#index'
post 'timer_session', to: 'timer_sessions#update'

post 'time_tracker/start', to: 'time_tracker#start', as: :start_time_tracker
post 'time_tracker/stop', to: 'time_tracker#stop', as: :stop_time_tracker
