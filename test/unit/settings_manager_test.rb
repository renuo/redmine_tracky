# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class SettingsManagerTest < ActiveSupport::TestCase
  test '#rounding_for_displayed_hours - default' do
    assert_equal SettingsManager.rounding_for_displayed_hours, 2
  end

  test '#max_hours_recorded_per_day - default' do
    assert_equal SettingsManager.max_hours_recorded_per_day, 24
  end

  test '#max_hours_recorded_per_session - default' do
    assert_equal SettingsManager.max_hours_recorded_per_session, 24
  end

  test '#visible_hints - default' do
    assert_equal SettingsManager.visible_hints, true
  end

  context 'with settings' do
    test '#max_hours_recorded_per_day - value' do
      SettingsManager.max_hours_recorded_per_day = '8'
      assert_equal SettingsManager.max_hours_recorded_per_day, 8
    end

    test '#max_hours_recorded_per_session - value' do
      SettingsManager.max_hours_recorded_per_session = '8'
      assert_equal SettingsManager.max_hours_recorded_per_session, 8
    end

    test '#min_hours_to_record - value' do
      SettingsManager.min_hours_to_record = '1'
      assert_equal SettingsManager.min_hours_to_record, 1
    end
  end
end
