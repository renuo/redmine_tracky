# frozen_string_literal: true

class TimeDiscrepancyLoader
  # base_query ==> Expected to be TimerSession.where(user_id: user.id)
  def initialize(base_query)
    @base_query = base_query
  end

  def where_time_not_adding_up
    build_query
  end

  private

  # TODO: rewrite to be in SQL rather than ruby
  def build_query
    @base_query.reject do |timer_session|
      hours_to_spend = timer_session.splittable_hours
      total_hours_recorded = timer_session.time_entries.sum(:hours)
      hours_to_spend == total_hours_recorded
    end
  end
end
