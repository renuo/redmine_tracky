# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class PermissionManagerTest < ActiveSupport::TestCase
  fixtures :users, :roles

  setup do
    User.current = User.find(2)
  end

  test 'can? - default' do
    assert_equal PermissionManager.new.can?(:edit, :timer_sessions), false
  end

  test 'cannot? - default' do
    assert_equal PermissionManager.new.cannot?(:edit, :timer_sessions), true
  end

  test 'forbidden_to_access_operation' do
    assert_equal PermissionManager.new.forbidden_to_access_operation, I18n.t('timer_sessions.permissions.not_allowed')
  end
end
