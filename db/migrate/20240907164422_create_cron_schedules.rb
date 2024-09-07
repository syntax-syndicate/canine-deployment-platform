class CreateCronSchedules < ActiveRecord::Migration[7.1]
  def change
    create_table :cron_schedules do |t|
      t.string :schedule, null: false
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
