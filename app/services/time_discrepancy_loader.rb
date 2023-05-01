# frozen_string_literal: true

class TimeDiscrepancyLoader
  DECIMALS_TO_ROUND_TO = 2

  def self.uneven_timer_sessions(scope = TimerSession.all)
    scope.joins(:time_entries)
         .group(:id, :timer_start, :timer_end)
         .having(<<~SQL)
           CAST(SUM(time_entries.hours)
           AS DECIMAL(10, #{DECIMALS_TO_ROUND_TO}))
           !=
           CAST(TIMESTAMPDIFF(SECOND, timer_sessions.timer_start, timer_sessions.timer_end) / 3600.0
           AS DECIMAL(10, #{DECIMALS_TO_ROUND_TO}))
         SQL
  end
end
