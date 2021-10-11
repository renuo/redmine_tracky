class CompletionController < TrackyController
  skip_before_action :verify_permission!

  SEARCH_LIMIT = 10
  PROJECT_RESULTS_LIMIT = 10

  def issues
    search_term = (params[:q] || params[:term]).to_s.strip
    scope = scoped_logins

    issues = if search_term.present?
      found_issues = []
      if search_term =~ /\A#?(\d+)\z/
        found_issues << scope.find_by(:id => $1.to_i)
      end
      found_issues += projects_with_issues(search_term)
      found_issues + scope.like(search_term).order(:id => :desc).limit(SEARCH_LIMIT).to_a
    else
      scope.order(:id => :desc).limit(SEARCH_LIMIT).to_a
    end

    render :json => format_issues_json(issues.compact)
  end

  private
  
  def projects_with_issues(search_term)
    project_arel = Project.arel_table
    Issue.joins(:project).includes(:project, :tracker)
      .where(project_arel[:name].lower.matches("%#{search_term.downcase}%")).limit(PROJECT_RESULTS_LIMIT)
  end

  def issue_includes(issue_query)
    issue_query.includes(:project, :tracker)
  end
  
  def scoped_logins
    scope = Issue.cross_project_scope(@project, params[:scope]).visible
    scope.includes(:project, :tracker)
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
