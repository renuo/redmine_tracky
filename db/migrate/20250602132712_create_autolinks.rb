MIGRATION_CLASS =
  if ActiveRecord::VERSION::MAJOR >= 5
    ActiveRecord::Migration["#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}"]
  else
    ActiveRecord::Migration
  end

class CreateAutolinks < MIGRATION_CLASS
  def change
    create_table :autolinks do |t|
      t.string :prefix, null: false
      t.string :target_url, null: false
      t.belongs_to :project, null: false
    end
  end
end
