# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class WorkReportQueryBuilderTest < ActiveSupport::TestCase
  test 'build query for day report' do
    work_report_query = WorkReportQuery.new(
      date: Date.new(2021, 10, 30).to_s,
      period: :day
    )
    expected_query = URI.decode('/time_entries?c%5B%5D=project&c%5B%5D=spent_on' \
                                '&c%5B%5D=activity&c%5B%5D=issue&c%5B%5D=comments' \
                                '&c%5B%5D=hours&f%5B%5D=spent_on&f%5B%5D=user_id' \
                                '&f%5B%5D=&group_by=&op%5Bspent_on%5D=%3E%3C&op%5Buser_id' \
                                '%5D=%3D&set_filter=1&sort=spent_on%3Adesc&t%5B%5D=hours&v%5Bspent_on' \
                                '%5D%5B%5D=2021-10-30&v%5Bspent_on%5D%5B%5D=2021-10-30&v%5Buser_id%5D%5B%5D=me')
    assert_equal expected_query, URI.decode(WorkReportQueryBuilder.new(work_report_query).build_query)
  end

  test 'does not panic on empty date' do
    work_report_query = WorkReportQuery.new(
      date: '',
      period: :day
    )
    todays_date = Time.zone.now.to_date
    expected_query = URI.decode('/time_entries?c%5B%5D=project&c%5B%5D=spent_on' \
                                '&c%5B%5D=activity&c%5B%5D=issue&c%5B%5D=comments' \
                                '&c%5B%5D=hours&f%5B%5D=spent_on&f%5B%5D=user_id' \
                                '&f%5B%5D=&group_by=&op%5Bspent_on%5D=%3E%3C&op%5Buser_id' \
                                '%5D=%3D&set_filter=1&sort=spent_on%3Adesc&t%5B%5D=hours&v%5Bspent_on' \
                                '%5D%5B%5D=' \
                                "#{todays_date.year}-" \
                                "#{todays_date.month.to_s.rjust(2, '0')}-#{todays_date.day.to_s.rjust(2, '0')}" \
                                '&v%5Bspent_on%5D%5B%5D=' \
                                "#{todays_date.year}-" \
                                "#{todays_date.month.to_s.rjust(2, '0')}-#{todays_date.day.to_s.rjust(2, '0')}" \
                                '&v%5Buser_id%5D%5B%5D=me')
    assert_equal expected_query, URI.decode(WorkReportQueryBuilder.new(work_report_query).build_query)
  end

  test 'build query for week report' do
    work_report_query = WorkReportQuery.new(
      date: Date.new(2021, 10, 30).to_s,
      period: :week
    )
    expected_query = URI.decode('/time_entries?c%5B%5D=project&c%5B%5D=spent_on' \
                                '&c%5B%5D=activity&c%5B%5D=issue&c%5B%5D=comments' \
                                '&c%5B%5D=hours&f%5B%5D=spent_on&f%5B%5D=user_id' \
                                '&f%5B%5D=&group_by=&op%5Bspent_on%5D=%3E%3C&op%5Buser_id' \
                                '%5D=%3D&set_filter=1&sort=spent_on%3Adesc&t%5B%5D=hours&v%5Bspent_on' \
                                '%5D%5B%5D=2021-10-25&v%5Bspent_on%5D%5B%5D=2021-10-31&v%5Buser_id%5D%5B%5D=me')
    assert_equal expected_query, URI.decode(WorkReportQueryBuilder.new(work_report_query).build_query)
  end

  test 'build query for month report' do
    work_report_query = WorkReportQuery.new(
      date: Date.new(2021, 10, 30).to_s,
      period: :month
    )
    expected_query = URI.decode('/time_entries?c%5B%5D=project&c%5B%5D=spent_on' \
                                '&c%5B%5D=activity&c%5B%5D=issue&c%5B%5D=comments' \
                                '&c%5B%5D=hours&f%5B%5D=spent_on&f%5B%5D=user_id' \
                                '&f%5B%5D=&group_by=&op%5Bspent_on%5D=%3E%3C&op%5Buser_id' \
                                '%5D=%3D&set_filter=1&sort=spent_on%3Adesc&t%5B%5D=hours&v%5Bspent_on' \
                                '%5D%5B%5D=2021-10-01&v%5Bspent_on%5D%5B%5D=2021-10-31&v%5Buser_id%5D%5B%5D=me')
    assert_equal expected_query, URI.decode(WorkReportQueryBuilder.new(work_report_query).build_query)
  end

  test 'build query for year report' do
    work_report_query = WorkReportQuery.new(
      date: Date.new(2021, 10, 30).to_s,
      period: :year
    )
    expected_query = URI.decode('/time_entries?c%5B%5D=project&c%5B%5D=spent_on' \
                                '&c%5B%5D=activity&c%5B%5D=issue&c%5B%5D=comments' \
                                '&c%5B%5D=hours&f%5B%5D=spent_on&f%5B%5D=user_id' \
                                '&f%5B%5D=&group_by=&op%5Bspent_on%5D=%3E%3C&op%5Buser_id' \
                                '%5D=%3D&set_filter=1&sort=spent_on%3Adesc&t%5B%5D=hours&v%5Bspent_on' \
                                '%5D%5B%5D=2021-01-01&v%5Bspent_on%5D%5B%5D=2021-12-31&v%5Buser_id%5D%5B%5D=me')
    assert_equal expected_query, URI.decode(WorkReportQueryBuilder.new(work_report_query).build_query)
  end
end
