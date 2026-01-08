class RenameStartedOnToWatchedOnInMovies < ActiveRecord::Migration[8.1]
  def change
    rename_column :movies, :started_on, :watched_on
  end
end
