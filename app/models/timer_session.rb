# frozen_string_literal: true

class TimerSession < RedmineTrackyApplicationRecord
  has_many :timer_session_issues, dependent: :destroy
  has_many :timer_session_time_entries, dependent: :destroy

  belongs_to :user

  has_many :issues, -> { distinct }, through: :timer_session_issues
  has_many :time_entries, through: :timer_session_time_entries

  validate :validate_session_attributes, on: :update

  scope :active_session, ->(user_id) { where(user_id: user_id, finished: false) }

  scope :finished_sessions, -> { where(finished: true) }

  scope :created_by, ->(user) { where(user_id: user.id) }

  scope :recorded_on, ->(user, date) { where(user_id: user.id, timer_start: date).sum(:hours) }

  validate :start_before_end_date

  before_save :set_recorded_hours

  attr_accessor :issue_id

  def splittable_hours
    ((timer_end || Time.zone.now) - timer_start) / 1.hour
  end

  def session_finished?
    timer_end.present?
  end

  def recorded_hours
    time_entries.sum(:hours)
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
    return if timer_start.before? timer_end

    errors.add(:timer_start, :after_end)
    errors.add(:timer_end, :before_start)
  end

  def limit_recorded_hours
    return if timer_start.blank? || timer_end.blank?

    max_hours_per_session = SettingsManager.max_hours_recorded_per_session.to_i
    max_hours_per_day = SettingsManager.max_hours_recorded_per_day.to_i
    hours_worked = TimerSession.recorded_on(user, timer_start.to_date)

    if splittable_hours <= max_hours_per_session && (hours_worked + splittable_hours) <= max_hours_per_day
      nil
    else
      errors.add(:timer_start, :limit_reached_session) if splittable_hours > max_hours_per_session
      errors.add(:timer_start, :limit_reached_day) if (splittable_hours + hours_worked) > max_hours_per_day
    end
  end

  def validate_session_attributes
    return unless finished_changed? || finished?

    start_and_end_present
    comment_present
    issues_selected
    limit_recorded_hours
  end

  def set_recorded_hours
    return unless timer_start.present? && timer_end.present?

    self.hours = (timer_end - timer_start) / 1.hour
  end
end
