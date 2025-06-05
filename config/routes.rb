# frozen_string_literal: true

# Plugin's routes
# See: http://guides.rubyonrails.org/routing.htm
resources :timer_sessions, only: %i[index edit update patch destroy]

get 'timer_sessions_report', to: 'timer_sessions#report', as: :timer_sessions_report
get 'timer_sessions_time_error/:id', to: 'timer_sessions#time_error', as: :timer_sessions_time_error
post 'timer_sessions_rebalance/:id', to: 'timer_sessions#rebalance', as: :timer_sessions_rebalance
post 'timer_sessions_continue/:id', to: 'timer_sessions#continue', as: :timer_sessions_continue

# avoid resources because there is either 0 or 1 object
post :time_tracker, to: 'time_tracker#create'
patch :time_tracker, to: 'time_tracker#update'
delete :time_tracker, to: 'time_tracker#destroy'

get 'completion/issues', to: 'completion#issues'
get 'projects/:project_id/autolinks', to: 'autolinks#index', as: :autolinks
