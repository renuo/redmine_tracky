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

  test '#max_hours_recorded_per_day - value' do
    Setting['plugin_redmine_tracky']['max_hours_recorded_per_day'] = '8'
    assert_equal SettingsManager.max_hours_recorded_per_day, 8
    Setting['plugin_redmine_tracky']['max_hours_recorded_per_day'] = nil
  end

  test '#max_hours_recorded_per_session - value' do
    Setting['plugin_redmine_tracky']['max_hours_recorded_per_session'] = '8'
    assert_equal SettingsManager.max_hours_recorded_per_session, 8
    Setting['plugin_redmine_tracky']['max_hours_recorded_per_session'] = nil
  end

  test '#min_hours_to_record - value' do
    Setting['plugin_redmine_tracky']['min_hours_to_record'] = '1'
    assert_equal SettingsManager.min_hours_to_record, 1
    Setting['plugin_redmine_tracky']['min_hours_to_record'] = nil
  end
end
