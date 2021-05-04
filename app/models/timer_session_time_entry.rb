class TimerSessionTimeEntry < ActiveRecord::Base
  belongs_to :timer_session
  belongs_to :time_entry
end
