# frozen_string_literal: true

class TimeSplitter
  def initialize(timer_session)
    @timer_session = timer_session
    @issues = timer_session.issues
  end

  def create_time_entries; end

  private

  def base_time_entry; end

  def create_time_entry; end
end
