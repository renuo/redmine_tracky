require File.expand_path("../../../application_system_test_case", __FILE__)

class TimerManagementTest < ApplicationSystemTestCase
  fixtures :projects, :users, :email_addresses, :roles, :members, :member_roles,
             :trackers, :projects_trackers, :enabled_modules, :issue_statuses, :issues,
             :enumerations, :custom_fields, :custom_values, :custom_fields_trackers,
             :watchers, :journals, :journal_details, :versions,
             :workflows, :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions


  test 'creation of timer' do
    log_user('admin', 'admin')
    visit timer_sessions_path

    find(I18n.t('timer_sessions.timer.start')).click
    assert has_content?(I18n.t('timer_sessions.timer.stop'))
    assert has_content?(I18n.t('timer_sessions.timer.cancel'))
  end
end
