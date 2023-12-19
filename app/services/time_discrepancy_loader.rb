# frozen_string_literal: true

class TimeDiscrepancyLoader
  DECIMALS_TO_ROUND_TO = 2

  # `scope` is an AR collection proxy for TimerSession
  def self.uneven_timer_session_ids(scope)
    scope.unscope(:includes)
         .joins(timer_session_time_entries: :time_entry)
         .group('timer_sessions.id')
         .having(
           <<~SQL
             CAST(SUM(time_entries.hours)
             AS DECIMAL(10, #{DECIMALS_TO_ROUND_TO}))
             !=
             CAST(timer_sessions.hours
             AS DECIMAL(10, #{DECIMALS_TO_ROUND_TO}))
           SQL
         )
         .pluck(:id, :hours)
         .map(&:first)
  end
end
