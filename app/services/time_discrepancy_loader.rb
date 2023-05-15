# frozen_string_literal: true

class TimeDiscrepancyLoader
  DECIMALS_TO_ROUND_TO = 2

  # `scope` is an AR collection proxy for TimerSession
  def self.uneven_timer_sessions(scope)
    scope.joins(:time_entries)
         .group(:id, :timer_start, :timer_end)
         .having(
           <<~SQL
             CAST(SUM(time_entries.hours)
             AS DECIMAL(10, #{DECIMALS_TO_ROUND_TO}))
             !=
             CAST((#{time_difference_expr}) / 3600.0
             AS DECIMAL(10, #{DECIMALS_TO_ROUND_TO}))
           SQL
         )
  end

  def self.time_difference_expr
    if using_postgresql?
      'EXTRACT(EPOCH FROM timer_sessions.timer_end) - EXTRACT(EPOCH FROM timer_sessions.timer_start)'
    else
      'TIMESTAMPDIFF(SECOND, timer_sessions.timer_start, timer_sessions.timer_end)'
    end
  end

  def self.using_postgresql?
    ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
  end
end
