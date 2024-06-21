# frozen_string_literal: true

class UnfinishedTimerSessionValidator < ActiveModel::Validator
  def validate(record)
    return if record.finished?

    @record = record

    validate_start_and_end_present
  end

  private

  def validate_start_and_end_present
    @record.errors.add(:timer_start, :blank) if @record.timer_start.blank?
    @record.errors.add(:timer_end, :blank) if @record.timer_end.blank?
  end
end
