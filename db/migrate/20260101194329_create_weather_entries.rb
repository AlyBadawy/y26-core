class CreateWeatherEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :weather_entries, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.date :date, null: false
      t.string :status, null: false

      t.timestamps
    end

    add_index :weather_entries, [:user_id, :date], unique: true
  end
end
