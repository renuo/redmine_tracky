# frozen_string_literal: true

class TimeEntityDecorator < SimpleDelegator
  include TimerSessionsHelper

  def initialize(time_entity)
    super
    __setobj__ time_entity
  end

  def recorded_hours
    timer_session? ? __getobj__.splittable_hours : __getobj__.hours
  end

  def issues
    timer_session? ? __getobj__.relevant_issues : [__getobj__.issue]
  end

  def entry_date
    timer_session? ? __getobj__.timer_start&.to_date : __getobj__.spent_on&.to_date
  end

  def start_time
    timer_session? ? __getobj__.timer_start : __getobj__.spent_on
  end

  def end_time
    timer_session? ? __getobj__.timer_end : (__getobj__.spent_on + __getobj__.hours.hours).to_datetime
  end

  def formated_session_time
    if timer_session?
      DisplayDateFormatBuilder.new(__getobj__.timer_start, __getobj__.timer_end).format
    else
      entry_date.strftime(DisplayDateFormatBuilder::DATE_FORMAT_WITH_YEAR)
    end
  end

  def overlaps?(other_entity)
    return false unless can_overlap_with?(other_entity)

    this_start = time_to_nearest_minute(start_time)
    this_end = time_to_nearest_minute(end_time)
    other_start = time_to_nearest_minute(other_entity.start_time)
    other_end = time_to_nearest_minute(other_entity.end_time)

    (this_start...this_end).overlaps?(other_start...other_end)
  end

  def can_overlap_with?(other_entity)
    return false if self == other_entity
    return false if __getobj__ == other_entity.__getobj__

    !(start_time.nil? || other_entity&.start_time.nil? || end_time.nil? || other_entity&.end_time.nil?)
  end

  def time_to_nearest_minute(time)
    return time unless time.is_a?(Time)

    seconds = time.sec

    if seconds < 30
      time - seconds
    else
      time + (60 - seconds)
    end
  end

  def timer_session?
    __getobj__.is_a?(TimerSession)
  end
end
