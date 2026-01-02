class CreateSleepHoursEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :sleep_hours_entries, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.date :date, null: false
      t.integer :hours, null: false, default: 8

      t.timestamps
    end

    add_index :sleep_hours_entries, [:user_id, :date], unique: true
  end
end
