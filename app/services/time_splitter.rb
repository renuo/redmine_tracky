# frozen_string_literal: true

class TimeSplitter
  def initialize(timer_session)
    @timer_session = timer_session
    @issues = timer_session.issues
  end

  def create_time_entries
    TimeEntry.transaction do
      time_entry = base_time_entry
      @issues.each do |issue|
        create_time_entry(issue, time_entry.dup)
      end
    end
  end

  private

  def base_time_entry
    time_entry = TimeEntry.new(
      comments: @timer_session.comments,
      hours: (@timer_session.splittable_hours || 0) / @issues.count,
      spent_on: @timer_session.timer_start,
      user_id: @timer_session.user_id,
      activity: TimeEntryActivity.default
    )
    default_activity(time_entry)
  end

  def default_activity(time_entry)
    time_entry.activity ||= TimeEntryActivity.default
    time_entry.activity ||= TimeEntryActivity.where(name: 'Entwicklung').first
    time_entry.activity ||= TimeEntryActivity.where(parent_id: nil, project_id: nil).first
    time_entry
  end

  def create_time_entry(issue, time_entry)
    time_entry.issue_id = issue.id
    time_entry.project_id = issue.project_id
    time_entry.save!
    TimerSessionTimeEntry.create!(
      time_entry: time_entry,
      timer_session: @timer_session
    )
  end
end
