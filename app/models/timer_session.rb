# frozen_string_literal: true

class TimerSession < RedmineTrackyApplicationRecord
  has_many :timer_session_issues, dependent: :destroy
  has_many :timer_session_time_entries, dependent: :destroy

  belongs_to :user

  validates_with UnfinishedTimerSessionValidator
  validates_with FinishedTimerSessionValidator

  has_many :issues, -> { distinct }, through: :timer_session_issues
  has_many :time_entries, through: :timer_session_time_entries

  validates :timer_start, presence: true
  before_save :set_recorded_hours

  scope :active, -> { where(finished: false) }
  scope :finished, -> { where(finished: true) }

  scope :created_by, ->(user) { where(user: user) }
  scope :recorded_on, ->(date) { where(timer_start: date) }

  attr_accessor :issue_id, :absolute_time

  def splittable_hours
    ((timer_end || Time.zone.now) - timer_start) / 1.hour
  end

  def session_finished?
    timer_end.present?
  end

  def recorded_hours
    time_entries.sum(:hours)
  end

  def relevant_issues
    if finished_was
      time_entries.includes(:issue).map(&:issue)
    else
      issues
    end
  end

  def overlaps?(other_session)
    return false unless timer_end.present? && other_session.timer_start.present?

    this_start = round_to_nearest_minute(timer_start)
    this_end = round_to_nearest_minute(timer_end)
    other_start = round_to_nearest_minute(other_session.timer_start)
    other_end = round_to_nearest_minute(other_session.timer_end)

    (this_start...this_end).overlaps?(other_start...other_end)
  end

  private

  def round_to_nearest_minute(time)
    Time.at((time.to_f / 60).round * 60).utc
  end

  def set_recorded_hours
    return unless timer_start.present? && timer_end.present?

    self.hours = (timer_end - timer_start) / 1.hour
  end
end
