class CreateTimerSessionTimeEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :timer_session_time_entries do |t|
      t.integer :timer_session_id
      t.integer :time_entry_id
    end
  end
end
