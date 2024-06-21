# frozen_string_literal: true

class FinishedTimerSessionValidator < ActiveModel::Validator
  def validate(record)
    validate_start_and_end_present
    validate_comment_present
    validate_issues_selected
    validate_minimal_duration
    validate_limit_recorded_hours
  end

  private

  def validate_start_and_end_present
    errors.add(:timer_start, :blank) if timer_start.blank?
    errors.add(:timer_end, :blank) if timer_end.blank?
  end

  def validate_comment_present
    errors.add(:comments, :blank) if comments.blank?
  end

  def validate_issues_selected
    errors.add(:issue_id, :no_selection) if issues.count.zero?
  end

  def validate_start_before_end_date
    return if timer_start.blank? || timer_end.blank?
    return if timer_end > timer_start

    errors.add(:timer_start, :after_end)
    errors.add(:timer_end, :before_start)
  end

  def validate_limit_recorded_hours
    return if timer_start.blank? || timer_end.blank?

    validate_day_limit
    validate_session_limit
  end

  def validate_minimal_duration
    errors.add(:timer_start, :too_short) if (splittable_hours / issues.count) < SettingsManager.min_hours_to_record.to_f
  end

  def validate_day_limit
    return unless (
        splittable_hours + TimerSession.created_by(user).recorded_on(timer_start.to_date).sum(:hours)
      ) > SettingsManager.max_hours_recorded_per_day.to_f

    errors.add(:timer_start, :limit_reached_day)
  end

  def validate_session_limit
    return unless splittable_hours > SettingsManager.max_hours_recorded_per_session.to_f

    errors.add(:timer_start, :limit_reached_session)
  end
end
