class TimerSession < ActiveRecord::Base
  SECONDS_IN_HOUR = 3600

  has_many :timer_session_issues, dependent: :destroy
  has_many :timer_session_time_entries, dependent: :destroy

  belongs_to :user

  has_many :issues, through: :timer_session_issues
  has_many :time_entries, through: :timer_session_time_entries

  scope :active_session, -> (user_id) { where(user_id: user_id, timer_end: nil) }
  
  scope :finished_sessions, -> { where.not(timer_end: nil) }

  def splittable_hours
    @splittable_hours ||= ((self.timer_end - self.timer_start) / SECONDS_IN_HOUR)
  end
end
