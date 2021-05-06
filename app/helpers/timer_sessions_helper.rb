# frozen_string_literal: true

module TimerSessionsHelper
  # Use in settings
  HOUR_FORMAT_PRECISION = 2

  def format_session_time(timer_start, timer_end)
    DisplayDateFormatBuilder.new(timer_start, timer_end).format
  end

  def format_worked_hours(hours)
    "#{number_with_precision(hours, precision: HOUR_FORMAT_PRECISION)} h"
  end

  def action_path_for_timer(timer_session)
    timer_session.persisted? ? stop_time_tracker_path : start_time_tracker_path
  end

  def select_options_for_work_period
    WorkReportQuery::AVAILABLE_PERIODS
      .map do |period|
      I18n.t(period.to_s,
             scope: 'timer_sessions.work_report_query.periods')
    end
      .zip(
        WorkReportQuery::AVAILABLE_PERIODS
      )
  end

  def format_block_date(date)
    current_date = Time.zone.now.to_date
    if current_date == date || current_date.yesterday == date || current_date.tomorrow == date
      format_relative_date(date, current_date)
    else
      I18n.l(date, format: I18n.t('timer_sessions.formats.date_with_year'))
    end
  end

  def format_relative_date(date, current_date)
    return I18n.t('timer_sessions.relative_times.tomorrow') if date == current_date.tomorrow
    return I18n.t('timer_sessions.relative_times.yesterday') if date == current_date.yesterday

    I18n.t('timer_sessions.relative_times.today')
  end

  def sum_work_hours(timer_sessions)
    total_hours = number_with_precision(timer_sessions.sum(&:splittable_hours),
                                        precision: HOUR_FORMAT_PRECISION)
    I18n.t('timer_sessions.index.table.total_hours_worked', hours: total_hours)
  end
end
