# frozen_string_literal: true

class IssueSearcher
  SEARCH_LIMIT = 10
  PROJECT_RESULTS_LIMIT = 10
  TICKET_OPEN_STATUS = true

  def call(search_term, scope)
    issues = if search_term.present?
               search_by_term(search_term, scope)
             else
               filter_closed_issues(scope).limit(SEARCH_LIMIT).order(id: :desc)
             end

    issues.compact.uniq(&:id)
  end

  private

  def search_by_term(search_term, scope)
    found_issues = []
    found_issues << find_by_id(search_term, scope)
    found_issues += hits_by_project(search_term)
    found_issues + hits_by_subject(search_term, scope)
  end

  def find_by_id(search_term, scope)
    return unless search_term =~ /\A#?(\d+)\z/

    scope.find_by(id: Regexp.last_match(1).to_i)
  end

  def hits_by_project(search_term)
    project_arel = Project.arel_table
    Issue.left_joins(:project, :time_entries)
         .select('issues.*, COUNT(time_entries.id) as time_entries_count')
         .group('issues.id')
         .where(project_arel[:name].lower.matches("%#{search_term.downcase}%"))
         .open(TICKET_OPEN_STATUS)
         .order('time_entries_count DESC')
         .limit(PROJECT_RESULTS_LIMIT)
  end

  def hits_by_subject(search_term, scope)
    filter_closed_issues(scope.like(search_term)).order(id: :desc).limit(SEARCH_LIMIT)
  end

  def filter_closed_issues(issues)
    issues.open(TICKET_OPEN_STATUS)
  end
end
