user_amount = 20
project_amount = 10
issue_per_project_amount = 10
members_per_project = 10
timelog_per_issue = 2
activity = TimeEntryActivity.create!(name: 'Entwicklung')
timelog_start = Date.new(2010, 1, 1).to_time
timelog_end = Time.zone.today.to_time

IssueStatus.create!(name: 'CURRENT')

Tracker.create!(name: "NOW", default_status: IssueStatus.first)
IssuePriority.create!(name: 'EOD')

print 'Create projects'
project_amount.times do |project_num|
  project = Project.create!(
    name: "Project #{project_num}",
    identifier: "project-#{project_num}",
    is_public: false,
    description: "Description for project #{project_num}"
  )

  # Assign members
  issue_per_project_amount.times do |issue_num|
    Issue.create!(
      subject: "Issue #{issue_num} for project #{project_num}",
      description: "Description for Issue #{issue_num} in project #{project_num}",
      tracker: Tracker.first,
      author: User.first,
      status: IssueStatus.first,
      priority: IssuePriority.first,
      project_id: project.id
    )
  end
  print '.'
end
