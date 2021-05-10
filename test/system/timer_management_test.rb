require File.expand_path("../../application_system_test_case", __FILE__)

def wait_for_load
  sleep 2
  yield
end

class TimerManagementTest < ApplicationSystemTestCase
  fixtures :projects, :users, :email_addresses, :roles, :members, :member_roles,
             :trackers, :projects_trackers, :enabled_modules, :issue_statuses, :issues,
             :enumerations, :custom_fields, :custom_values, :custom_fields_trackers,
             :watchers, :journals, :journal_details, :versions,
             :workflows, :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions

  setup do
    log_user('admin', 'admin')
    visit timer_sessions_path
  end

  test 'creation of timer' do
    visit timer_sessions_path
    find('[data-timer-start-button]').click
    assert has_content?(I18n.t('timer_sessions.timer.stop'))
    assert has_content?(I18n.t('timer_sessions.timer.cancel'))
  end

  test 'cancelation of timer' do
    timer_session = FactoryBot.create(:timer_session, finished: false, user: User.current)
    wait_for_load do
      visit timer_sessions_path
      find('[data-timer-cancel-button]').click
      assert has_content?(I18n.t('timer_sessions.timer.start'))
    end
  end

  test 'update running timer' do
    timer_session = FactoryBot.create(:timer_session, finished: false, user: User.current)
    visit timer_sessions_path
    fill_in 'timer_session_comments', with: 'Working on stuff'
    assert timer_session.comments, 'Working on stuff'
  end

  test 'stopping of timer with invalid attributes' do
    timer_session = FactoryBot.create(:timer_session, finished: false, user: User.current)
    p timer_session
    visit timer_sessions_path
    find('[data-timer-stop-button]').click
    assert has_content?(I18n.t('activerecord.errors.models.timer_session.attributes.issue_id.no_selection', locale: :en))
  end

  test 'stopping timer with valid attributes' do
    timer_session = FactoryBot.create(:timer_session, finished: false, user: User.current)
    TimerSessionIssue.create!(
      issue_id: Issue.find(1).id,
      timer_session_id: timer_session.id
    )
    visit timer_sessions_path
    find('[data-timer-stop-button]').click
  end
end
