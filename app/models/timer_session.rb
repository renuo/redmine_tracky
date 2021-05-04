class TimerSession < ActiveRecord::Base
  has_many :timer_session_issues, dependent: :destroy
  has_many :timer_session_time_entries, dependent: :destroy

  belongs_to :user

  has_many :issues, through: :timer_session_issues
  has_many :time_entries, through: :timer_session_time_entries
end
