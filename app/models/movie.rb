class Movie < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :status, presence: true, inclusion: { in: %w[to_watch watching watched abandoned] }
  validates :rating, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 5 }, allow_nil: true

  enum :status, { to_watch: "to_watch", watching: "watching", watched: "watched", abandoned: "abandoned" }
end
