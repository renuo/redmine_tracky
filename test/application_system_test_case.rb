# frozen_string_literal: true

require File.expand_path('test_helper', __dir__)
require File.expand_path('../../../test/application_system_test_case', __dir__)

# borrowed and adapted from Redmine application system test case. The url assertion was a source of timing problems.
# https://github.com/redmine/redmine/blob/06bbaebef8366bf19f73da0bf4e1315d23dc4697/test/application_system_test_case.rb#L69-L78
def login_user(login, password)
  visit '/my/page'
  assert_current_path '/login', ignore_query: true
  within('#login-form form') do
    fill_in 'username', with: login
    fill_in 'password', with: password
    find('input[name=login]').click
  end
  assert_current_path '/my/page', ignore_query: true
end
