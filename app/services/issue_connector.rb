# frozen_string_literal: true

class IssueConnector
  def initialize(user, issues, timer_session)
    @user = user
    @issues = issues
    @timer_session = timer_session
    # TODO: replace with ActiveModel errors
    @errors = []
  end

  def validate_issues
    issues_exist?
  end

  def issues_exist?; end

  def create_connection; end
end
