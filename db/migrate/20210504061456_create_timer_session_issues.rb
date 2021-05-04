class CreateTimerSessionIssues < ActiveRecord::Migration[6.1]
  def change
    create_table :timer_session_issues do |t|
      t.integer :timer_session_id
      t.integer :issue_id
    end
  end
end
