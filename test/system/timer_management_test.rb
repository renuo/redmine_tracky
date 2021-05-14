require File.expand_path("../../application_system_test_case", __FILE__)

SimpleCov.command_name 'test:system'

class TimerManagementTest < ApplicationSystemTestCase
  fixtures :projects, :users, :email_addresses, :roles, :members, :member_roles,
             :trackers, :projects_trackers, :enabled_modules, :issue_statuses, :issues,
             :enumerations, :custom_fields, :custom_values, :custom_fields_trackers,
             :watchers, :journals, :journal_details, :versions,
             :workflows, :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions


  setup do
    log_user('admin', 'admin')
    User.current = User.find(1)
    visit timer_sessions_path
  end

  test 'creation of timer' do
    find('[data-timer-start-button]').click
    assert has_content?(I18n.t('timer_sessions.timer.stop'))
    assert has_content?(I18n.t('timer_sessions.timer.cancel'))
  end

  test 'cancelation of timer' do
    timer_session = FactoryBot.create(:timer_session, finished: false, user: User.current)
    visit timer_sessions_path
    assert has_content?(I18n.t('timer_sessions.index.title'))
    find('[data-timer-cancel-button]').click
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
    timer_session = FactoryBot.create(:timer_session, finished: false, user: User.current)
    visit timer_sessions_path
    assert has_content?(I18n.t('timer_sessions.index.title'))
    find('[data-timer-stop-button]').click
    assert has_content?(I18n.t('activerecord.errors.models.timer_session.attributes.issue_id.no_selection',
                               locale: :en))
  end

  test 'stopping timer with valid attributes' do
    timer_session = FactoryBot.create(:timer_session, :with_issues, finished: false, user: User.current)
    timer_session.reload
    visit timer_sessions_path
    assert has_content?(I18n.t('timer_sessions.index.title'))
    refute TimerSession.last.finished?
    find('[data-timer-stop-button]').click
    assert has_content?(timer_session.comments)
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
    time = Time.zone.now
    fill_in 'timer_session_timer_end', with: time.strftime(I18n.t('timer_sessions.formats.datetime_format'))
    find('[data-timer-stop-button]').click
    assert has_content?(timer_session.comments)
    assert_equal(time.strftime(I18n.t('timer_sessions.formats.datetime_format')),
      TimerSession.last.timer_end.strftime(I18n.t('timer_sessions.formats.datetime_format')))
  end
end
