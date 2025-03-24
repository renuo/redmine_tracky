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
    # User.current = User.find(1)
    # User.current.preference.update(time_zone: 'Tijuana')
  end

  test 'creation of timer' do
    log_user('admin', 'admin')
    visit timer_sessions_path
    find('[data-name="timer-start"]').click
    assert has_content?(I18n.t('timer_sessions.timer.stop'))
    assert has_content?(I18n.t('timer_sessions.timer.cancel'))
  end

  test 'cancelation of timer' do
    FactoryBot.create(:timer_session, finished: false, user: User.current)
    log_user('admin', 'admin')
    visit timer_sessions_path
    assert has_content?(I18n.t('timer_sessions.index.title'))
    find('[data-name="timer-cancel"]').click
    page.driver.browser.switch_to.alert.accept
    assert has_content?(I18n.t('timer_sessions.timer.start'))
  end

  test 'update running timer' do
    timer_session = FactoryBot.create(:timer_session, finished: false, user: User.current)
    log_user('admin', 'admin')
    visit timer_sessions_path
    assert has_content?(I18n.t('timer_sessions.index.title'))
    fill_in 'timer_session_comments', with: 'Working on stuff'
    assert timer_session.comments, 'Working on stuff'
  end

  test 'stopping of timer with invalid attributes' do
    FactoryBot.create(:timer_session, finished: false, user: User.current)
    log_user('admin', 'admin')
    visit timer_sessions_path
    assert has_content?(I18n.t('timer_sessions.index.title'))
    find('[data-name="timer-stop"]').click
    assert has_content?(I18n.t('activerecord.errors.models.timer_session.attributes.issue_id.no_selection',
                               locale: :en))
  end

  test 'starting of timer with invalid attributes and present issues' do
    time_in_user_time_zone = User.current.convert_time_to_user_timezone(Time.zone.now)
    log_user('admin', 'admin')
    visit timer_sessions_path

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
    log_user('admin', 'admin')
    visit timer_sessions_path

    visit timer_sessions_path
    assert has_content?(I18n.t('timer_sessions.index.title'))
    assert_not TimerSession.last.finished?
    find('[data-name="timer-stop"]').click
    assert has_content?(timer_session.comments)
    assert TimerSession.last.finished?
  end

  test 'stopping timer with correction' do
    log_user('admin', 'admin')
    visit timer_sessions_path
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
    FactoryBot.create(:timer_session, :with_issues, finished: false, user: User.current)
    log_user('admin', 'admin')
    visit timer_sessions_path
    visit timer_sessions_path(issue_ids: [Issue.first.id, Issue.second.id])
    assert has_content?(Issue.first.subject)
    assert has_content?(Issue.second.subject)
  end
end
