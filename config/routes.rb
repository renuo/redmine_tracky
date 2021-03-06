# frozen_string_literal: true

# Plugin's routes
# See: http://guides.rubyonrails.org/routing.htm
resources :timer_sessions, only: %i[index edit update patch destroy]

get 'timer_sessions_report', to: 'timer_sessions#report', as: :timer_sessions_report
get 'timer_sessions_time_error/:id', to: 'timer_sessions#time_error', as: :timer_sessions_time_error
post 'timer_sessions_rebalance/:id', to: 'timer_sessions#rebalance', as: :timer_sessions_rebalance
post 'timer_sessions_continue/:id', to: 'timer_sessions#continue', as: :timer_sessions_continue

post 'time_tracker/start', to: 'time_tracker#start', as: :start_time_tracker
post 'time_tracker/stop', to: 'time_tracker#stop', as: :stop_time_tracker
post 'time_tracker/update', to: 'time_tracker#update', as: :update_time_tracker

get 'completion/issues', to: 'completion#issues'
