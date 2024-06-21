# frozen_string_literal: true

class FinishedTimerSessionValidator < ActiveModel::Validator
  def validate(record)
    return unless record.finished?

    @record = record

    validate_start_and_end_present
    validate_comment_present
    validate_issues_selected
    validate_minimal_duration
    validate_limit_recorded_hours
  end

  private

  def validate_start_and_end_present
    @record.errors.add(:timer_start, :blank) if @record.timer_start.blank?
    @record.errors.add(:timer_end, :blank) if @record.timer_end.blank?
  end

  def validate_comment_present
    @record.errors.add(:comments, :blank) if @record.comments.blank?
  end

  def validate_issues_selected
    @record.errors.add(:issue_id, :no_selection) if @record.issues.count.zero?
  end

  def validate_start_before_end_date
    return if @record.timer_start.blank? || @record.timer_end.blank?
    return if @record.timer_end > @record.timer_start

    @record.errors.add(:timer_start, :after_end)
    @record.errors.add(:timer_end, :before_start)
  end

  def validate_limit_recorded_hours
    return if @record.timer_start.blank? || @record.timer_end.blank?

    validate_day_limit
    validate_session_limit
  end

  def validate_minimal_duration
    @record.errors.add(:timer_start, :too_short) if (@record.splittable_hours / @record.issues.count) < SettingsManager.min_hours_to_record.to_f
  end

  def validate_day_limit
    return unless (
        @record.splittable_hours + TimerSession.created_by(@record.user).recorded_on(@record.timer_start.to_date).sum(:hours)
      ) > SettingsManager.max_hours_recorded_per_day.to_f

    @record.errors.add(:timer_start, :limit_reached_day)
  end

  def validate_session_limit
    return unless @record.splittable_hours > SettingsManager.max_hours_recorded_per_session.to_f

    @record.errors.add(:timer_start, :limit_reached_session)
  end
end
