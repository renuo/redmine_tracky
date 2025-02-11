# frozen_string_literal: true

class FinishedTimerSessionValidator < ActiveModel::Validator
  def validate(record)
    return unless record.finished?

    @record = record

    validate_start_and_end_present
    validate_comment_present
    validate_minimal_duration
    validate_day_limit
    validate_session_limit

    # issues get connected after the session is finished
    return unless record.persisted?

    validate_issues_selected
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

  def validate_minimal_duration
    return unless (@record.splittable_hours / @record.issues.count) < SettingsManager.min_hours_to_record.to_f

    @record.errors.add(:timer_start,
                       :insufficient_recording_time)
  end

  def validate_day_limit
    return if (
        @record.splittable_hours + TimerSession.created_by(@record.user)
        .recorded_on(@record.timer_start.to_date).sum(:hours)
      ) <= SettingsManager.max_hours_recorded_per_day.to_f

    @record.errors.add(:timer_start, :limit_reached_day)
  end

  def validate_session_limit
    return if @record.splittable_hours <= SettingsManager.max_hours_recorded_per_session.to_f

    @record.errors.add(:timer_start, :limit_reached_session)
  end
end
