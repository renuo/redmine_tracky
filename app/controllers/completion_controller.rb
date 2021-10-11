# frozen_string_literal: true

class CompletionController < TrackyController
  skip_before_action :verify_permission!

  SEARCH_LIMIT = 10
  PROJECT_RESULTS_LIMIT = 10
  TICKET_OPEN_STATUS = true

  def issues
    search_term = (params[:q] || params[:term]).to_s.strip
    scope = scoped_logins

    issues = order_issues(if search_term.present?
                            search_by_term(search_term, scope)
                          else
                            issue_order(scope).limit(SEARCH_LIMIT)
                          end)

    render json: format_issues_json(issues)
  end

  private

  def search_by_term(search_term, scope)
    found_issues = []
    found_issues << scope.find_by(id: Regexp.last_match(1).to_i) if search_term =~ /\A#?(\d+)\z/
    found_issues += projects_with_issues(search_term)
    found_issues + issue_order(scope.like(search_term)).limit(SEARCH_LIMIT)
  end

  def projects_with_issues(search_term)
    project_arel = Project.arel_table
    issue_order(Issue.joins(:project).includes(:project, :tracker)
      .where(project_arel[:name].lower.matches("%#{search_term.downcase}%"))
      .open(TICKET_OPEN_STATUS))
      .limit(PROJECT_RESULTS_LIMIT)
  end

  def issue_includes(issue_query)
    issue_query.includes(:project, :tracker)
  end

  def issue_order(issue_query)
    issue_query.order(id: :desc)
  end

  def order_issues(issues)
    issues.compact.sort_by(&:id).reverse.uniq(&:id)
  end

  def scoped_logins
    scope = Issue.cross_project_scope(@project, params[:scope]).visible
    issue_includes(scope.open(TICKET_OPEN_STATUS))
  end

  def format_issues_json(issues)
    issues.map do |issue|
      {
        'id' => issue.id,
        'label' => "#{issue.project} - #{issue.tracker} ##{issue.id}: #{issue.subject.to_s.truncate(255)}",
        'value' => issue.id
      }
    end
  end
end
