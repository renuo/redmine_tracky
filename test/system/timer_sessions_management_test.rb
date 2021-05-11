require File.expand_path("../../application_system_test_case", __FILE__)

class TimerSessionsManagementTest < ApplicationSystemTestCase
  fixtures :projects, :users, :email_addresses, :roles, :members, :member_roles,
             :trackers, :projects_trackers, :enabled_modules, :issue_statuses, :issues,
             :enumerations, :custom_fields, :custom_values, :custom_fields_trackers,
             :watchers, :journals, :journal_details, :versions,
             :workflows, :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions

  setup do
    log_user('admin', 'admin')
    User.current = User.find(1)
    @timer_sessions = FactoryBot.create_list(:timer_session, 3,
                                             :with_issues,
                                             :with_time_entries,
                                             user: User.current)
    visit timer_sessions_path
  end

  test '#index' do
    visit timer_sessions_path
    @timer_sessions.each do | timer_session |
      assert has_content?(timer_session.comments)
    end
  end

  test '#filter' do
    visit timer_sessions_path
    @timer_sessions.each do | timer_session |
      assert has_content?(timer_session.comments)
    end
  end

  test '#edit' do
    visit timer_sessions_path
    find('[data-timer-session-edit-button]', match: :first).click
    assert has_content?(I18n.t('timer_sessions.edit.title'))
  end
end
