# frozen_string_literal: true

module TimerSessionsHelper
  def precision_for_display_hours
    SettingsManager.rounding_for_displayed_hours
  end

  def format_session_time(timer_start, timer_end)
    DisplayDateFormatBuilder.new(timer_start, timer_end).format
  end

  def format_worked_hours(hours)
    "#{number_with_precision(hours, precision: precision_for_display_hours)} h"
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

  def format_time_entry_information(time_entry)
    issue = time_entry.issue
    "##{issue.id}: #{issue.subject} - #{format_worked_hours(time_entry.hours)}"
  end

  def sum_work_hours(timer_sessions)
    total_hours = number_with_precision(
      timer_sessions
      .sum do |timer_session|
        number_with_precision(timer_session.splittable_hours,
                              precision: precision_for_display_hours).to_f
      end,
      precision: precision_for_display_hours
    )
    I18n.t('timer_sessions.index.table.total_hours_worked', hours: total_hours)
  end

  def issue_link_list(issues)
    issues.map do |issue|
      link_to issue.subject, issue_path(issue)
    end.join(', ')
  end
end
