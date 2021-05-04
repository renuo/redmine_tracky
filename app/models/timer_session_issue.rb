class TimerSessionIssue < ActiveRecord::Base
  belongs_to :timer_session
  belongs_to :issue
end
