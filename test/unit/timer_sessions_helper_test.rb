# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class TimerSessionsHelperTest < ActionView::TestCase
  tests TimerSessionsHelper

  fixtures :issues, :time_entries

  test '#precision_for_display_hours' do
    assert_equal precision_for_display_hours, 2
  end

  test '#format_session_time' do
    assert_equal format_session_time(
      Time.zone.local(2001, 2, 3, 4, 5, 6),
      Time.zone.local(2001, 2, 3, 4, 5, 6)
    ), '04:05 - 04:05'
  end

  test '#format_worked_hours' do
    assert_equal format_worked_hours(0.5), '0.50 h'
  end

  test '#select_options_for_work_period' do
    assert_equal [['Day', :day], ['Week', :week], ['Month', :month], ['Year', :year]],
                 select_options_for_work_period
  end

  test '#format_block_date' do
    assert_equal 'Today', format_block_date(Time.zone.now.to_date)
  end

  test '#format_block_date - non relative date' do
    assert_equal I18n.l(Time.zone.now.to_date + 2.days, format: I18n.t('timer_sessions.formats.date_with_year')),
                 format_block_date(Time.zone.now.to_date + 2.days)
  end

  test '#format_time_entry_information' do
    assert_equal '#1: Cannot print recipes - 4.25 h',
                 format_time_entry_information(TimeEntry.first)
  end

  test '#sum_work_hours' do
    timer_session = FactoryBot.create(:timer_session,
        :with_issues,
        :with_time_entries,
        user: User.current)
    assert_equal 'Total Hours: 1.00 h', sum_work_hours([timer_session])
  end

  test '#issue_link_list' do
    assert_equal ['<a href="/issues/1">1: Cannot print recipes</a>'], issue_link_list([Issue.first])
  end
end
