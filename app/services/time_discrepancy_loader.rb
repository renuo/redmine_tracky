# frozen_string_literal: true

class TimeDiscrepancyLoader
  DECIMALS_TO_ROUND_TO = 2

  # `scope` is an AR collection proxy for TimerSession
  def self.uneven_timer_sessions(scope)
    scope.joins(timer_session_time_entries: :time_entry)
         .group('timer_sessions.id')
         .having(
           <<~SQL
             timer_sessions.hours != CAST(SUM(time_entries.hours) AS DECIMAL(10, #{DECIMALS_TO_ROUND_TO}))
             OR timer_sessions.hours != #{time_difference_expr} / 3600
           SQL
         )
  end

  def self.time_difference_expr
    if using_postgresql?
      '(EXTRACT(EPOCH FROM timer_sessions.timer_end) - EXTRACT(EPOCH FROM timer_sessions.timer_start))'
    else
      'TIMESTAMPDIFF(SECOND, timer_sessions.timer_start, timer_sessions.timer_end)'
    end
  end

  def self.using_postgresql?
    ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
  end
end
