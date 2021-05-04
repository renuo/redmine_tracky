# frozen_string_literal: true

module TimerSessionsHelper
  def format_session_time(timer_start, timer_end)
    DisplayDateFormatBuilder.new(timer_start, timer_end).format
  end

  def format_worked_hours(hours)
    "#{hours} h"
  end

  def format_block_date(date)
    return I18n.t('timer_sessions.relative_times.today') if date == Time.zone.now.to_date

    current_date = Time.zone.now.to_date
    if date == current_date.yesterday
      I18n.t('timer_sessions.relative_times.today')
    else
      I18n.l(date, format: I18n.t('timer_sessions.formats.date_with_year'))
    end
  end

  def sum_work_hours(timer_sessions)
    total_hours = timer_sessions.sum(&:splittable_hours)
    I18n.t('timer_sessions.index.table.total_hours_worked', hours: total_hours)
  end
end
