MIGRATION_CLASS =
  if ActiveRecord::VERSION::MAJOR >= 5
    ActiveRecord::Migration["#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}"]
  else
    ActiveRecord::Migration
  end

class CreateTimerSessionTimeEntries < MIGRATION_CLASS
  def change
    create_table :timer_session_time_entries do |t|
      t.integer :timer_session_id
      t.integer :time_entry_id
    end
  end
end
