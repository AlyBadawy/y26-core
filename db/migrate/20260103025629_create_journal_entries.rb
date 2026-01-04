class CreateJournalEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :journal_entries, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :title, null: false
      t.text :content
      t.datetime :journaled_at, null: false

      t.timestamps
    end

    add_index :journal_entries, [:user_id, :journaled_at]
  end
end
