# frozen_string_literal: true

class TimerEntityCleaner
  def initialize(timer_session)
    @timer_session = timer_session
  end

  def run
    delete_time_entries
  end

  private

  def delete_time_entries
    @timer_session.time_entries.destroy_all
  end
end
