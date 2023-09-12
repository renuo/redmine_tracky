# frozen_string_literal: true

class IssueSearcher
  SEARCH_LIMIT = 10
  PROJECT_RESULTS_LIMIT = 10
  TICKET_OPEN_STATUS = true

  def call(search_term, scope)
    issues = if search_term.present?
               search_by_term(search_term, scope)
             else
               filter_closed_issues(issue_order(scope)).limit(SEARCH_LIMIT)
             end

    order_issues(issues)
  end

  private

  def search_by_term(search_term, scope)
    found_issues = []
    found_issues << scope.find_by(id: Regexp.last_match(1).to_i) if search_term =~ /\A#?(\d+)\z/
    found_issues += projects_with_issues(search_term)
    found_issues + issue_order(filter_closed_issues(scope.like(search_term))).limit(SEARCH_LIMIT)
  end

  def projects_with_issues(search_term)
    project_arel = Project.arel_table
    issue_order(Issue.joins(:project).includes(:project, :tracker)
                     .where(project_arel[:name].lower.matches("%#{search_term.downcase}%"))
                     .open(TICKET_OPEN_STATUS))
      .limit(PROJECT_RESULTS_LIMIT)
  end

  def issue_order(issue_query)
    issue_query.order(id: :desc)
  end

  def order_issues(issues)
    issues.compact.sort_by(&:id).reverse.uniq(&:id)
  end

  def filter_closed_issues(issues)
    issues.open(TICKET_OPEN_STATUS)
  end
end
