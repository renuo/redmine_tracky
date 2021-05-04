# frozen_string_literal: true

class TimerSessionIssue < RedmineTrackyApplicationRecord
  belongs_to :timer_session
  belongs_to :issue
end
