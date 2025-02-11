# frozen_string_literal: true

class TimeRebalancer
  def initialize(issues, timer_session)
    @issues = (issues || []).map(&:to_i)
    @issue_ids = timer_session.relevant_issues.map(&:id).map(&:to_i)
    @timer_session = timer_session
    validate
  end

  def rebalance_entries
    return unless @timer_session.valid?

    if issues_changed?
      handle_issues_changed
    else
      handle_issues_not_changed
    end
  end

  def force_rebalance
    delete_connection_entities
    rebuild_connection
    rebuild_time_entries
  end

  private

  def validate
    @timer_session.errors.add(:issue_id, :no_selection) if @issues.blank?
  end

  def handle_issues_changed
    delete_connection_entities
    rebuild_connection
    rebuild_time_entries if @timer_session.finished? || @timer_session.finished_changed?
  end

  def handle_issues_not_changed
    return unless @timer_session.time_entries

    update_times if times_changed?
    update_comments if comments_changed?
  end

  def update_times
    new_time = @timer_session.splittable_hours / @issues.count
    @timer_session.errors.add(:timer_start, :insufficient_recording_time) if new_time < SettingsManager.min_hours_to_record
    return unless @timer_session.valid?

    @timer_session.time_entries.each do |time_entry|
      time_entry.update!(hours: new_time, spent_on: @timer_session.timer_start)
    end
  end

  def update_comments
    @timer_session.time_entries.each do |time_entry|
      time_entry.update!(comments: @timer_session.comments)
    end
  end

  def comments_changed?
    @timer_session.saved_change_to_comments?
  end

  def times_changed?
    @timer_session.saved_change_to_timer_start? || @timer_session.saved_change_to_timer_end?
  end

  def issues_changed?
    return false unless @issues

    @issues != @issue_ids
  end

  def delete_connection_entities
    TimerEntityCleaner.new(@timer_session).run
  end

  def rebuild_time_entries
    time_splitter = TimeSplitter.new(@timer_session, Issue.where(id: @issues))
    time_splitter.create_time_entries
  end

  def rebuild_connection
    IssueConnector.new(@issues, @timer_session).run
  end
end
