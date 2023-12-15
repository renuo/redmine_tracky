# frozen_string_literal: true

class TimeDiscrepancyLoader
  DECIMALS_TO_ROUND_TO = 2

  # `scope` is an AR collection proxy for TimerSession
  def self.uneven_timer_sessions(scope)
    scope.joins(timer_session_time_entries: :time_entry)
         .group('timer_sessions.id')
         .having("#{round('timer_sessions.hours')} != #{round('SUM(time_entries.hours)')}")
  end

  def self.using_postgresql?
    ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
  def self.round(attribute)
    "CAST(#{attribute} AS DECIMAL(10, #{DECIMALS_TO_ROUND_TO}))"
  end

  # def self.uneven_timer_session_ids(scope)
  #   debugger
  #   return [] if scope.empty?

  #   scope.joins(timer_session_time_entries: :time_entry)
  #        .group('timer_sessions.id')
  #        .having("CAST(SUM(time_entries.hours) AS DECIMAL(10, #{DECIMALS_TO_ROUND_TO})) != ?",
  #                scope.first.hours.round(DECIMALS_TO_ROUND_TO))
  #        .ids
  # end
end
