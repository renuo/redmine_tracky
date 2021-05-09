class CreateTimerSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :timer_sessions do |t|
      t.integer :user_id
      t.string :comments
      t.datetime :timer_start
      t.datetime :timer_end
      t.boolean :finished, default: false
    end
  end
end
