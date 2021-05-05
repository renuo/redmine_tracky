# frozen_string_literal: true

class TimerSession < RedmineTrackyApplicationRecord
  SECONDS_IN_HOUR = 3600

  has_many :timer_session_issues, dependent: :destroy
  has_many :timer_session_time_entries, dependent: :destroy

  belongs_to :user

  has_many :issues, through: :timer_session_issues
  has_many :time_entries, through: :timer_session_time_entries

  validate :validate_session_attributes, on: :update

  scope :active_session, ->(user_id) { where(user_id: user_id, finished: false) }

  scope :finished_sessions, -> { where(finished: true) }

  validate :start_before_end_date

  attr_accessor :issue_id

  def splittable_hours
    @splittable_hours ||= ((timer_end - timer_start) / SECONDS_IN_HOUR)
  end

  def session_finished?
    timer_end.present?
  end

  def start_and_end_present
    errors.add(:timer_start, :blank) if timer_start.blank?
    errors.add(:timer_end, :blank) if timer_end.blank?
  end

  def comment_present
    errors.add(:comments, :blank) if comments.blank?
  end

  def issues_selected
    errors.add(:issue_id, :no_selection) if issues.count.zero?
  end

  def start_before_end_date
    return if timer_start.blank? || timer_end.blank?
    return unless timer_end <= timer_start

    errors.add(:timer_start, :after_end)
    errors.add(:timer_end, :before_start)
  end

  def validate_session_attributes
    return unless finished_changed? || finished?

    start_and_end_present
    comment_present
    issues_selected
  end
end
