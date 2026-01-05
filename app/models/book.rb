class Book < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :author, presence: true
  validates :status, presence: true, inclusion: { in: %w[to_read reading read abandoned] }
  validates :rating, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 5 }, allow_nil: true

  enum :status, { to_read: "to_read", reading: "reading", read: "read", abandoned: "abandoned" }
end
