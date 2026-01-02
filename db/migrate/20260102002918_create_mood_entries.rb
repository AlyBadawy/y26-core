class CreateMoodEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :mood_entries, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.date :date, null: false
      t.integer :status, null: false, default: 3

      t.timestamps
    end

    add_index :mood_entries, [:user_id, :date], unique: true
  end
end
