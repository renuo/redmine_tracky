# frozen_string_literal: true

require File.expand_path('../application_system_test_case', __dir__)

SimpleCov.command_name 'test:system'

class TimerManagementTest < ApplicationSystemTestCase
  fixtures :projects, :users, :email_addresses, :roles, :members, :member_roles,
           :trackers, :projects_trackers, :enabled_modules, :issue_statuses, :issues,
           :enumerations, :custom_fields, :custom_values, :custom_fields_trackers,
           :watchers, :journals, :journal_details, :versions,
           :workflows, :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions

  setup do
    login_user('admin', 'admin')
    User.current = User.find(1)
    # User.current.preference.update(time_zone: 'Tijuana')
    visit timer_sessions_path
  end

  test 'creation of timer' do
    find('[data-name="timer-start"]').click
    assert has_content?(I18n.t('timer_sessions.timer.stop'))
    assert has_content?(I18n.t('timer_sessions.timer.cancel'))
  end

  test 'cancelation of timer' do
    FactoryBot.create(:timer_session, finished: false, user: User.current)
    visit timer_sessions_path
    assert has_content?(I18n.t('timer_sessions.index.title'))
    find('[data-name="timer-cancel"]', wait: 5).click
    page.driver.browser.switch_to.alert.accept
    assert has_content?(I18n.t('timer_sessions.timer.start'))
  end

  test 'update running timer' do
    timer_session = FactoryBot.create(:timer_session, finished: false, user: User.current)
    visit timer_sessions_path
    assert has_content?(I18n.t('timer_sessions.index.title'))
    fill_in 'timer_session_comments', with: 'Working on stuff'
    assert timer_session.comments, 'Working on stuff'
  end

  test 'stopping of timer with invalid attributes' do
    FactoryBot.create(:timer_session, finished: false, user: User.current)
    visit timer_sessions_path
    assert has_content?(I18n.t('timer_sessions.index.title'))
    find('[data-name="timer-stop"]').click
    assert has_content?(I18n.t('activerecord.errors.models.timer_session.attributes.issue_id.no_selection',
                               locale: :en))
  end

  test 'starting of timer with invalid attributes and present issues' do
    time_in_user_time_zone = User.current.convert_time_to_user_timezone(Time.zone.now)

    fill_in 'timer_session[issue_id]', with: Issue.first.subject
    sleep(1)
    find('#timer_session_issue_id').send_keys(:arrow_down)
    find('#timer_session_issue_id').send_keys(:tab)

    fill_in 'timer_session[issue_id]', with: Issue.second.subject
    sleep(1)
    find('#timer_session_issue_id').send_keys(:arrow_down)
    find('#timer_session_issue_id').send_keys(:tab)

    fill_in 'timer_session_timer_start',
            with: time_in_user_time_zone.strftime(I18n.t('timer_sessions.formats.datetime_format'))
    fill_in 'timer_session_timer_end',
            with: time_in_user_time_zone.strftime(I18n.t('timer_sessions.formats.datetime_format'))

    subjects = [Issue.first.subject, Issue.second.subject]
    find('[data-name="timer-start"]').click
    assert has_content?(subjects[0])
    assert has_content?(subjects[1])
  end

  test 'stopping timer with valid attributes' do
    timer_session = FactoryBot.create(:timer_session, :with_issues, finished: false, user: User.current)
    timer_session.reload

    visit timer_sessions_path
    assert has_content?(I18n.t('timer_sessions.index.title'))
    assert_not TimerSession.last.finished?

    find('[data-name="timer-stop"]', wait: 5).click
    assert has_content?(timer_session.comments, wait: 5)
    assert TimerSession.last.finished?
  end

  test 'stopping timer with correction' do
    timer_session = FactoryBot.create(:timer_session, finished: false, user: User.current, timer_end: nil)
    TimerSessionIssue.create!(
      issue_id: Issue.find(1).id,
      timer_session_id: timer_session.id
    )
    visit timer_sessions_path
    assert_nil TimerSession.last.timer_end
    time_in_user_time_zone = User.current.convert_time_to_user_timezone(Time.zone.now)

    fill_in 'timer_session_timer_end',
            with: time_in_user_time_zone.strftime(I18n.t('timer_sessions.formats.datetime_format'))
    find('[data-name="timer-stop"]').click
    assert has_content?(timer_session.comments)
    assert_equal(time_in_user_time_zone.strftime(I18n.t('timer_sessions.formats.datetime_format')),
                 TimerSession.last.timer_end.strftime(I18n.t('timer_sessions.formats.datetime_format')))
  end

  test 'loading timer with issues from url' do
    visit timer_sessions_path(issue_ids: [Issue.first.id, Issue.second.id])

    assert_text Issue.first.subject
    assert_text Issue.second.subject
  end

  test 'loading timer with empty issues from url' do
    visit timer_sessions_path(issue_ids: [])

    assert_no_text Issue.first.subject
    assert_no_text Issue.second.subject
  end

  test 'loading timer with comments from url' do
    visit timer_sessions_path(comments: 'Meeting with team')

    assert_equal 'Meeting with team', find('#timer_session_comments').value
  end

  test 'loading timer with timer_start from url' do
    visit timer_sessions_path(timer_start: '01.01.2026 09:00')

    assert_equal '01.01.2026 09:00', find('#timer_session_timer_start').value
  end

  test 'loading timer with timer_end from url' do
    visit timer_sessions_path(timer_end: '01.01.2026 17:00')

    assert_equal '01.01.2026 17:00', find('#timer_session_timer_end').value
  end

  test 'loading timer with all query params from url' do
    visit timer_sessions_path(
      issue_ids: [Issue.first.id],
      comments: 'Sprint planning',
      timer_start: '01.01.2026 09:00',
      timer_end: '01.01.2026 10:00'
    )

    assert_text I18n.t('timer_sessions.timer.share_prefilled')
    assert_text Issue.first.subject
    assert_equal 'Sprint planning', find('#timer_session_comments').value
    assert_equal '01.01.2026 09:00', find('#timer_session_timer_start').value
    assert_equal '01.01.2026 10:00', find('#timer_session_timer_end').value
  end

  test 'share button is visible and clickable' do
    visit timer_sessions_path

    fill_in 'timer_session_comments', with: 'Pairing session'

    find('[data-name="timer-share"]', wait: 5).click
    assert_text I18n.t('timer_sessions.timer.share_copied')
  end

  test 'share button is visible when timer is active' do
    FactoryBot.create(:timer_session, :with_issues, finished: false, user: User.current)
    visit timer_sessions_path

    assert has_content?(I18n.t('timer_sessions.timer.stop'))
    find('[data-name="timer-share"]', wait: 5).click
    assert_text I18n.t('timer_sessions.timer.share_copied')
  end

  test 'shows only ignored notice when active session exists and url has params' do
    FactoryBot.create(:timer_session, finished: false, user: User.current)
    visit timer_sessions_path(comments: 'Meeting', issue_ids: [Issue.first.id])

    assert_text I18n.t('timer_sessions.timer.share_ignored')
    assert_no_text I18n.t('timer_sessions.timer.share_prefilled')
  end

  test 'shows only prefilled notice when no active session and url has params' do
    visit timer_sessions_path(comments: 'Sprint planning', timer_start: '01.01.2026 09:00')

    assert_text I18n.t('timer_sessions.timer.share_prefilled')
    assert_no_text I18n.t('timer_sessions.timer.share_ignored')
  end

  test 'clears share query params from URL after prefilling' do
    visit timer_sessions_path(
      comments: 'Sprint planning',
      timer_start: '01.01.2026 09:00',
      timer_end: '01.01.2026 10:00'
    )

    assert_text I18n.t('timer_sessions.timer.share_prefilled')
    assert_equal 'Sprint planning', find('#timer_session_comments').value

    current_url = page.current_url
    assert_not current_url.include?('comments='), 'URL should not contain comments param'
    assert_not current_url.include?('timer_start='), 'URL should not contain timer_start param'
    assert_not current_url.include?('timer_end='), 'URL should not contain timer_end param'
  end

  test 'preserves filter parameters when stopping a timer' do
    filter_date = 1.week.ago.strftime('%Y-%m-%d')
    current_date = Date.today.strftime('%Y-%m-%d')

    visit timer_sessions_path(filter: { min_date: filter_date, max_date: current_date })

    assert_equal filter_date, find('input[name="filter[min_date]"]').value
    assert_equal current_date, find('input[name="filter[max_date]"]').value

    find('[data-name="timer-start"]').click
    assert has_content?(I18n.t('timer_sessions.timer.stop'))

    fill_in 'timer_session[issue_id]', with: Issue.first.subject
    sleep(1)
    find('#timer_session_issue_id').send_keys(:arrow_down)
    find('#timer_session_issue_id').send_keys(:tab)

    find('[data-name="timer-stop"]', wait: 5).click

    assert_equal filter_date, find('input[name="filter[min_date]"]').value
    assert_equal current_date, find('input[name="filter[max_date]"]').value
  end

  test 'preserves filter parameters when canceling a timer' do
    filter_date = 1.week.ago.strftime('%Y-%m-%d')
    current_date = Date.today.strftime('%Y-%m-%d')

    visit timer_sessions_path(filter: { min_date: filter_date, max_date: current_date })

    assert_equal filter_date, find('input[name="filter[min_date]"]').value
    assert_equal current_date, find('input[name="filter[max_date]"]').value

    find('[data-name="timer-start"]').click
    assert has_content?(I18n.t('timer_sessions.timer.cancel'))

    find('[data-name="timer-cancel"]', wait: 5).click
    page.driver.browser.switch_to.alert.accept

    assert_equal filter_date, find('input[name="filter[min_date]"]').value
    assert_equal current_date, find('input[name="filter[max_date]"]').value
  end
end
