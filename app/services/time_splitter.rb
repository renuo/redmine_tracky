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
    hours_for_entry = if @timer_session.splittable_hours.zero?
                        SettingsManager.min_hours_to_record
                      else
                        @timer_session.splittable_hours
                      end

    split_hours = hours_for_entry / @issues.count.to_f
    time_entry = TimeEntry.new(
      comments: @timer_session.comments,
      hours: split_hours,
      spent_on: @timer_session.timer_start,
      user_id: @timer_session.user_id,
      activity: TimeEntryActivity.default
    )
    default_activity(time_entry)
  end

  # Taken from https://github.com/renuo/redmine_auto_time_entries/blob/master/lib/redmine_adapter.rb
  # Line: 26
  # Accessed on: 07.05.2021
  def default_activity(time_entry)
    possible_activities.each do |activity|
      time_entry.activity ||= activity unless time_entry.valid?
    end

    time_entry
  end

  def possible_activities
    [
      TimeEntryActivity.default,
      *TimeEntryActivity.where(
        name: %w[Development Entwicklung]
      ).or(
        TimeEntryActivity.where(
          parent_id: nil,
          project_id: nil
        )
      ).to_a
    ]
  end

  def create_time_entry(issue, time_entry)
    time_entry.update!(
      issue: issue,
      project: issue.project
    )
    TimerSessionTimeEntry.create!(
      time_entry: time_entry,
      timer_session: @timer_session
    )
  end
end
