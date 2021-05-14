# frozen_string_literal: true

class TimerEntityCleaner
  def initialize(timer_session)
    @timer_session = timer_session
  end

  def run
    delete_time_entries
    delete_connection_to_issues
  end

  private

  def delete_connection_to_issues
    @timer_session.timer_session_issues.destroy_all
  end

  def delete_time_entries
    @timer_session.time_entries.destroy_all
    @timer_session.timer_session_time_entries.destroy_all
  end
end
