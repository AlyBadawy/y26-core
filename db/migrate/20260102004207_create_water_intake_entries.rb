class CreateWaterIntakeEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :water_intake_entries, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.date :date, null: false
      t.integer :cups, null: false, default: 1

      t.timestamps
    end

    add_index :water_intake_entries, [:user_id, :date], unique: true
  end
end
