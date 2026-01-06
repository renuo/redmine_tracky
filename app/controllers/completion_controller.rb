# frozen_string_literal: true

class CompletionController < ApplicationController
  def issues
    issues = IssueSearcher.new.call(search_term, scoped_issues)
    render json: format_issues_json(issues)
  end

  private

  def search_params
    params.permit(:q, :term)
  end

  def search_term
    (search_params[:q] || search_params[:term]).to_s.strip
  end

  def scoped_issues
    Issue
      .cross_project_scope(@project, params[:scope])
      .visible
      .joins(:project)
      .where('projects.status = ?', Project::STATUS_ACTIVE)
      .includes(:project, :tracker)
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
