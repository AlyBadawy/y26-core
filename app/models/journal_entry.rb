class JournalEntry < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :journaled_at, presence: true
end
