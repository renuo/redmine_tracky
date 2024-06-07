# frozen_string_literal: true

# Plugin's routes
# See: http://guides.rubyonrails.org/routing.htm
resources :timer_sessions, only: %i[index edit update patch destroy]

get 'timer_sessions_report', to: 'timer_sessions#report', as: :timer_sessions_report
get 'timer_sessions_time_error/:id', to: 'timer_sessions#time_error', as: :timer_sessions_time_error
post 'timer_sessions_rebalance/:id', to: 'timer_sessions#rebalance', as: :timer_sessions_rebalance
post 'timer_sessions_continue/:id', to: 'timer_sessions#continue', as: :timer_sessions_continue

post 'time_tracker/create_or_update', to: 'time_tracker#create_or_update', as: :time_tracker_create_or_update
delete 'time_tracker/cancel', to: 'time_tracker#cancel', as: :time_tracker_cancel

get 'completion/issues', to: 'completion#issues'
