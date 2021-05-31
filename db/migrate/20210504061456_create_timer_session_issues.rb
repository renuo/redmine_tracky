MIGRATION_CLASS =
  if ActiveRecord::VERSION::MAJOR >= 5
    ActiveRecord::Migration["#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}"]
  else
    ActiveRecord::Migration
  end

class CreateTimerSessionIssues < MIGRATION_CLASS
  def change
    create_table :timer_session_issues do |t|
      t.integer :timer_session_id
      t.integer :issue_id
    end
  end
end
