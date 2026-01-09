class CreateMovies < ActiveRecord::Migration[8.1]
  def change
    create_table :movies, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :title, null: false
      t.string :genre
      t.integer :rating
      t.date :watched_on
      t.string :status, null: false, default: "to_watch"
      t.text :notes

      t.timestamps
    end

    add_index :movies, :status
    add_index :movies, :rating
    add_index :movies, :genre
  end
end
