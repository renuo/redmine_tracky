# frozen_string_literal: true

class IssueSearcher
  SEARCH_LIMIT = 10
  PROJECT_RESULTS_LIMIT = 10
  TICKET_OPEN_STATUS = true

  def call(search_term, issues)
    issues = issues.on_active_project

    issues = if search_term.present?
               search_by_term(search_term, issues)
             else
               issues.open(true).limit(SEARCH_LIMIT).order(id: :desc)
             end

    issues.compact.uniq(&:id)
  end

  private

  def search_by_term(search_term, issues)
    found_issues = []
    found_issues << find_by_id(search_term, issues)
    found_issues += hits_by_project(search_term)
    found_issues + hits_by_subject(search_term, issues)
  end

  def find_by_id(search_term, issues)
    return unless search_term =~ /\A#?(\d+)\z/

    issues.find_by(id: Regexp.last_match(1).to_i)
  end

  def hits_by_project(search_term)
    project_arel = Project.arel_table
    Issue.left_joins(:time_entries)
         .select('issues.*, COUNT(time_entries.id) as time_entries_count')
         .group('issues.id')
         .on_active_project
         .where(project_arel[:name].lower.matches("%#{search_term.downcase}%"))
         .open(TICKET_OPEN_STATUS)
         .order('time_entries_count DESC')
         .limit(PROJECT_RESULTS_LIMIT)
  end

  def hits_by_subject(search_term, issues)
    issues.like(search_term).open(true).order(id: :desc).limit(SEARCH_LIMIT)
  end
end
