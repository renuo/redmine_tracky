# frozen_string_literal: true

require File.expand_path('../application_system_test_case', __dir__)

class TimerSessionsManagementTest < ApplicationSystemTestCase
  fixtures :projects, :users, :email_addresses, :roles, :members, :member_roles,
           :trackers, :projects_trackers, :enabled_modules, :issue_statuses, :issues,
           :enumerations, :custom_fields, :custom_values, :custom_fields_trackers,
           :watchers, :journals, :journal_details, :versions,
           :workflows, :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions,
           :time_entries

  setup do
    login_user('admin', 'admin')
    User.current = User.find(1)
    # User.current.preference.update(time_zone: 'Tijuana')
    @timer_sessions = FactoryBot.create_list(:timer_session, 3,
                                             :with_issues,
                                             :with_time_entries,
                                             user: User.current)
    visit timer_sessions_path
  end

  test 'index' do
    @timer_sessions.each do |timer_session|
      assert has_content?(timer_session.comments)
    end
  end

  test 'index - does not raise error when rendering time entries on same date' do
    last_session = @timer_sessions.last
    entry = TimeEntry.create!(issue: Issue.first, user: last_session.user, hours: 1,
                              spent_on: last_session.timer_start)
    visit timer_sessions_path
    entry.destroy!
  end

  test 'filter' do
    @timer_sessions.each do |timer_session|
      assert has_content?(timer_session.comments)
    end
  end

  test 'edit' do
    find('[data-timer-session-edit-button]', match: :first).click
    assert has_content?(I18n.t('timer_sessions.edit.title'))
  end

  test 'update' do
    find('[data-timer-session-edit-button]', match: :first).click
    within '.edit-modal' do
      fill_in TimerSession.human_attribute_name(:comments), with: 'Working on stuff'
      find('[data-modal-update-button]', match: :first).click
    end
    assert has_content?(@timer_sessions.last.comments)
    assert_equal 'Working on stuff', @timer_sessions.last.reload.comments
  end

  test 'continue' do
    assert_equal 3, TimerSession.count
    find('[data-timer-session-continue-button]', match: :first).click
    assert has_content?(TimerSession.last.comments, wait: 5)
    assert_equal 4, TimerSession.count
    assert_equal 4, TimerSessionIssue.count
  end

  test 'destroy' do
    assert_equal 3, TimerSession.count
    find('[data-timer-session-destroy-button]', match: :first).click
    page.driver.browser.switch_to.alert.accept
    assert has_content?(@timer_sessions.first.comments)
    assert has_content?(@timer_sessions.second.comments)
    assert_equal 2, TimerSession.count
    assert_equal 2, TimerSessionIssue.count
    assert_equal 2, TimerSessionTimeEntry.count
  end

  test 'discrepancy in time sum' do
    @timer_sessions.last.time_entries.each do |time_entry|
      time_entry.update(hours: 0.01)
    end
    visit timer_sessions_path
    find('[data-timer-session-discrepancy-button]', match: :first).click
    assert has_content?(I18n.t('resolution_options.options',
                               scope: 'timer_sessions.messaging.errors.discrepancy_in_time_sum'))
  end

  test 'spent - time query' do
    click_button I18n.t('timer_sessions.work_report_query.buttons.submit')
    assert has_content?(I18n.t(:label_spent_time))
  end

  test 'preserves filter parameters when updating a timer session' do
    filter_date = 1.week.ago.strftime('%Y-%m-%d')
    current_date = Date.today.strftime('%Y-%m-%d')

    visit timer_sessions_path(filter: { min_date: filter_date, max_date: current_date })

    assert_equal filter_date, find('input[name="filter[min_date]"]').value
    assert_equal current_date, find('input[name="filter[max_date]"]').value

    find('[data-timer-session-edit-button]', match: :first).click
    assert has_content?(I18n.t('timer_sessions.edit.title'))

    within '.edit-modal' do
      fill_in TimerSession.human_attribute_name(:comments), with: 'Updated with filters'
      find('[data-modal-update-button]', match: :first).click
    end

    assert_equal filter_date, find('input[name="filter[min_date]"]').value
    assert_equal current_date, find('input[name="filter[max_date]"]').value
  end
end
