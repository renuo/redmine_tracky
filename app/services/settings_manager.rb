# frozen_string_literal: true

class SettingsManager
  DEFAULT_HOUR_FORMAT_PRECISION = 2
  DEFAULT_MAX_HOURS_PER_SESSION = 24
  DEFAULT_MAX_HOURS_PER_DAY = 24
  DEFAULT_VISIBLE_HINTS = true
  MIN_HOURS_TO_RECORD = 0.01

  class << self
    def rounding_for_displayed_hours
      settings_object['displayed_hours_rounding']&.to_i || DEFAULT_HOUR_FORMAT_PRECISION
    end

    def max_hours_recorded_per_day
      settings_object['max_hours_recorded_per_day']&.to_i || DEFAULT_MAX_HOURS_PER_DAY
    end

    def max_hours_recorded_per_session
      settings_object['max_hours_recorded_per_session']&.to_i || DEFAULT_MAX_HOURS_PER_SESSION
    end

    def min_hours_to_record
      settings_object['min_hours_to_record']&.to_i || MIN_HOURS_TO_RECORD
    end

    def visible_hints
      settings_object['visible_hints']
    end

    private

    def settings_object
      Setting['plugin_redmine_tracky']
    end
  end
end
