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
    timer_session? ? __getobj__.issues : [__getobj__.issue]
  end

  def entry_date
    timer_session? ? __getobj__.timer_start&.to_date : __getobj__.spent_on&.to_date
  end

  def start_time
    timer_session? ? __getobj__.timer_start : __getobj__.spent_on
  end

  def formated_session_time
    if timer_session?
      DisplayDateFormatBuilder.new(__getobj__.timer_start, __getobj__.timer_end).format
    else
      entry_date.strftime(DisplayDateFormatBuilder::DATE_FORMAT_WITH_YEAR)
    end
  end

  def timer_session?
    __getobj__.is_a?(TimerSession)
  end
end
