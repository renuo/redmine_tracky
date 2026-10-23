# frozen_string_literal: true

require File.expand_path('../application_system_test_case', __dir__)

class SessionResetTest < ApplicationSystemTestCase
  fixtures :users, :email_addresses

  setup do
    login_user('admin', 'admin')
  end

  test 'teardown waits for pending requests before the session is reset' do
    slow_request = ActiveSupport::Notifications.subscribe('start_processing.action_controller') { sleep 1 }
    execute_script("jQuery.get('/my/page')")

    before_teardown

    assert_equal 0, evaluate_script('jQuery.active')
  ensure
    ActiveSupport::Notifications.unsubscribe(slow_request)
  end
end
