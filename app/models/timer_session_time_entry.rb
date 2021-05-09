# frozen_string_literal: true

class TimerSessionTimeEntry < RedmineTrackyApplicationRecord
  belongs_to :timer_session
  belongs_to :time_entry, dependent: :destroy
end
