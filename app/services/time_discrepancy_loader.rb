# frozen_string_literal: true

class TimeDiscrepancyLoader
  DECIMALS_TO_ROUND_TO = 2
  VIRTUAL_ATTRIBUTE = 'discrepancy_detected'

  def initialize(timer_sessions)
    @timer_sessions = timer_sessions
    @timer_session_arel = TimerSession.arel_table
    @time_entry_arel = TimeEntry.arel_table
  end

  def load_with_discrepancy_state
    return [] if @timer_sessions.empty? || @timer_sessions.nil?

    discrepancy_lookup = select_clause
                         .pluck(:id, :"#{VIRTUAL_ATTRIBUTE}").to_h
    @timer_sessions.each do |timer_session|
      timer_session.discrepancy_detected = discrepancy_lookup[timer_session.id]
    end
    @timer_sessions
  end

  private

  def select_clause
    TimerSession.find_by_sql(
      virtual_discrepancy_select_query
        .where(
          @timer_session_arel[:id].in(
            @timer_sessions.map(&:id)
          )
        ).from(@timer_session_arel)
          .group(@timer_session_arel[:id]).to_sql
    )
  end

  def virtual_discrepancy_select_query
    joined = TimerSession.joins(
      ArelHelpers.join_association(TimerSession, { timer_session_time_entries: :time_entry })
    )
      joined.select(
      "#{round_aggregation(@time_entry_arel[:hours].sum).to_sql}
      != #{round_aggregation(@timer_session_arel[:hours]).to_sql}
      AS #{VIRTUAL_ATTRIBUTE}"
    )
  end

  def round_aggregation(aggregation)
    Arel::Nodes::NamedFunction.new(
      'ROUND',
      [
        Arel::Nodes::NamedFunction.new('CAST',
                                       [
                                         aggregation.as('Numeric')
                                       ]), DECIMALS_TO_ROUND_TO
      ]
    )
  end
end
