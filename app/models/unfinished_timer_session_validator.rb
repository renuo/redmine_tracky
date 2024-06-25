# frozen_string_literal: true

class UnfinishedTimerSessionValidator < ActiveModel::Validator
  def validate(record)
    @record = record

    validate_start_before_end_date
  end

  def validate_start_before_end_date
    return if @record.timer_start.blank? || @record.timer_end.blank?
    return if @record.timer_end > @record.timer_start

    @record.errors.add(:timer_start, :after_end)
    @record.errors.add(:timer_end, :before_start)
  end
end
