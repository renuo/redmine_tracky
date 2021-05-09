# frozen_string_literal: true

class SettingsManager
  DEFAULT_HOUR_FORMAT_PRECISION = 2
  DEFAULT_MAX_HOURS_PER_SESSION = 24
  DEFAULT_MAX_HOURS_PER_DAY = 24
  DEFAULT_VISIBLE_HINTS = true

  class << self
    def rounding_for_displayed_hours
      settings_object['displayed_hours_rounding']&.to_i || DEFAULT_HOUR_FORMAT_PRECISION
    end

    def max_hours_recorded_per_day
      settings_object['max_hours_recorded_per_day'] || DEFAULT_MAX_HOURS_PER_DAY
    end

    def max_hours_recorded_per_session
      settings_object['max_hours_recorded_per_session'] || DEFAULT_MAX_HOURS_PER_SESSION
    end

    def visible_hints
      settings_object['visible_hints'] || DEFAULT_VISIBLE_HINTS
    end

    def settings_object
      Setting['plugin_redmine_tracky']
    end
  end
end
