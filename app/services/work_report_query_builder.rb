class WorkReportQueryBuilder
  AVAILABLE_PERIODS = %i[day week month year]

  def initialize(date, period: :week)
    @date = date
    @period = period
  end

  def build_report_query

  end
end
