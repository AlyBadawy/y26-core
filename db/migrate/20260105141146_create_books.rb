class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :title, null: false
      t.string :author, null: false
      t.string :genre
      t.integer :rating
      t.date :started_on
      t.date :finished_on
      t.string :status, null: false, default: "to_read"
      t.text :notes

      t.timestamps
    end

    add_index :books, :status
    add_index :books, :rating
    add_index :books, :genre
  end
end
