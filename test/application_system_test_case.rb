# frozen_string_literal: true

ENV['_ORIGINAL_TZ'] = ENV.fetch('TZ', nil)
ENV['TZ'] = 'Europe/Zurich'

require File.expand_path('test_helper', __dir__)
require File.expand_path('test/application_system_test_case', Dir.pwd)

# Redmine core dropped this from its own ApplicationSystemTestCase (redmine/redmine@19a0472, 2026-06-22),
# which lets Rails default to multiple parallel workers and makes every system test collide on one Capybara session.
ApplicationSystemTestCase.parallelize(workers: 1)

class ApplicationSystemTestCase
  # Capybara deletes cookies before leaving the page, so a response still in flight would log in the next test
  def before_teardown
    super
  ensure
    wait_for_ajax
  end
end

# borrowed and adapted from Redmine application system test case.
# https://github.com/redmine/redmine/blob/06bbaebef8366bf19f73da0bf4e1315d23dc4697/test/application_system_test_case.rb#L69-L78
def login_user(login, password)
  page.reset!
  visit '/my/page'
  assert_current_path '/login', ignore_query: true
  within('#login-form form') do
    fill_in 'username', with: login
    fill_in 'password', with: password
    find('input[name=login]').click
  end
  assert_current_path '/my/page', ignore_query: true
end

Minitest.after_run do
  ENV['TZ'] = ENV.fetch('_ORIGINAL_TZ', nil)
  ENV['_ORIGINAL_TZ'] = nil
end
