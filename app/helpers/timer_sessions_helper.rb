# frozen_string_literal: true

module TimerSessionsHelper
  MAX_SUBJECT_LENGTH = 50

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
      return I18n.t('timer_sessions.relative_times.tomorrow') if date == current_date.tomorrow
      return I18n.t('timer_sessions.relative_times.yesterday') if date == current_date.yesterday

      I18n.t('timer_sessions.relative_times.today')
    else
      I18n.l(date, format: I18n.t('timer_sessions.formats.date_with_year_and_weekday'))
    end
  end

  def format_time_entry_information(time_entry)
    issue = time_entry.issue
    issue_information = "##{issue.id}: #{issue.subject}"
    [
      issue_information,
      format_worked_hours(time_entry.hours)
    ].join(' - ')
  end

  def sum_work_hours(timer_sessions)
    total_hours = number_with_precision(
      timer_sessions
      .sum(&:splittable_hours),
      precision: precision_for_display_hours
    )
    I18n.t('timer_sessions.index.table.total_hours_worked', hours: total_hours)
  end

  def issue_information(issue)
    subject = issue.subject
    issue_information = issue.id.to_s
    [
      issue_information,
      "#{subject[0..(MAX_SUBJECT_LENGTH - issue_information.length)]}#{subject_label_trail(subject)}"
    ].join(': ')
  end

  def subject_label_trail(subject)
    return '...' if subject.length > MAX_SUBJECT_LENGTH
  end

  def issue_link_list(issues)
    issues.map do |issue|
      link_to issue_information(issue), issue_path(issue)
    end
  end
end
