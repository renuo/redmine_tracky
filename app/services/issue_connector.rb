# frozen_string_literal: true

class IssueConnector
  attr_reader :errors

  def initialize(issues, timer_session)
    @issues = Array.wrap(issues).map(&:to_i)
    @timer_session = timer_session
    # TODO: replace with ActiveModel errors
    @errors = []
  end

  def run
    validate_issues
    create_connections
  end

  private

  def validate_issues
    issues_exist?
  end

  def issues_exist?
    found_issues = Issue.where(id: @issues)
    invalid_issue_ids = @issues - found_issues.pluck(:id)
    if invalid_issue_ids.count.positive?
      invalid_issue_ids.each do |invalid_issue_id|
        @errors << { invalid_issue_id: invalid_issue_id }
      end
    end
    @errors.count.zero?
  end

  def create_connections
    return false unless @errors.count.zero?

    TimerSessionIssue.transaction do
      @issues.each do |issue_id|
        TimerSessionIssue.create!(
          timer_session_id: @timer_session.id,
          issue_id: issue_id
        )
      end
    end
  end
end
