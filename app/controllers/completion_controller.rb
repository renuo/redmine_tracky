# frozen_string_literal: true

class CompletionController < ApplicationController
  def issues
    search_term = (params[:q] || params[:term]).to_s.strip
    scope = scoped_issues
    issues = IssueSearcher.new.call(search_term, scope)

    render json: format_issues_json(issues)
  end

  private

  def scoped_issues
    scope = Issue.cross_project_scope(@project, params[:scope]).visible
    scope.includes(:project, :tracker)
  end

  def format_issues_json(issues)
    issues.map do |issue|
      {
        'id' => issue.id,
        'label' => "#{issue.project} - #{issue.tracker} ##{issue.id}: #{issue.subject.to_s.truncate(255)}",
        'subject' => issue.subject.to_s.truncate(255).to_s,
        'value' => issue.id,
        'project' => issue.project.to_s
      }
    end
  end
end
