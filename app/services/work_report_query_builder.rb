# frozen_string_literal: true

class WorkReportQueryBuilder
  include Rails.application.routes.url_helpers

  DATE_FORMAT_FOR_QUERY = '%Y-%m-%d'
  COLUMNS_TO_QUERY = %w[project spent_on activity issue comments hours].freeze
  BETWEEN_OPERATOR = '><'
  FILTERS_TO_USE = ['spent_on', 'user_id', ''].freeze
  QUERY_CURRENT_USER_SYMBOL = 'me'
  FILTER_STATUS = '1'

  def initialize(work_report_query)
    @work_report_query = work_report_query
    @date = begin
      Date.parse(@work_report_query.date)
    rescue StandardError
      Time.zone.now.to_date
    end
  end

  def build_query
    date_range = build_date_range.map { |date| date.strftime(DATE_FORMAT_FOR_QUERY) }
    build_report_query(date_range)
  end

  private

  def build_report_query(date_range)
    time_entries_path(
      set_filter: FILTER_STATUS, sort: 'spent_on:desc',
      f: FILTERS_TO_USE,
      op: { spent_on: BETWEEN_OPERATOR, user_id: '=' },
      v: { spent_on: [date_range.first, date_range.last], user_id: [QUERY_CURRENT_USER_SYMBOL] },
      c: COLUMNS_TO_QUERY, group_by: '', t: ['hours']
    )
  end

  def build_date_range
    case @work_report_query.period.to_sym
    when :day
      [@date, @date]
    when :week
      [@date.beginning_of_week, @date.end_of_week]
    when :month
      [@date.beginning_of_month, @date.end_of_month]
    when :year
      [@date.beginning_of_year, @date.end_of_year]
    end
  end
end
