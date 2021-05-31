MIGRATION_CLASS =
  if ActiveRecord::VERSION::MAJOR >= 5
    ActiveRecord::Migration["#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}"]
  else
    ActiveRecord::Migration
  end

class CreateTimerSessions < MIGRATION_CLASS
  def change
    create_table :timer_sessions do |t|
      t.integer :user_id, null: false
      t.string :comments
      t.float :hours
      t.datetime :timer_start, null: false
      t.datetime :timer_end
      t.boolean :finished, default: false
    end
  end
end
