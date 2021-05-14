# frozen_string_literal: true

class IssueConnector
  attr_reader :errors
  attr_accessor :logger

  def initialize(issues, timer_session)
    @issues = Array.wrap(issues).map(&:to_i).uniq
    @timer_session = timer_session
    @errors = []
    self.logger = ::Rails.logger
  end

  def run
    validate_issues ? create_connections : false
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
      issue_creation = @issues.map do |issue_id|
        TimerSessionIssue.create(timer_session_id: @timer_session.id, issue_id: issue_id)
      end

      @errors << { issue_connection_creation: :failed } if issue_creation.any?(false)
      logger.error 'Issue arose during connection creation' if issue_creation.any?(false)
      raise ActiveRecord::Rollback, 'Issue arose during connection creation' if issue_creation.any?(false)
    end
    @errors.count.zero?
  end
end
