class CreateGratitudeEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :gratitude_entries, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.date :date, null: false
      t.string :content, null: false

      t.timestamps
    end
  end
end
