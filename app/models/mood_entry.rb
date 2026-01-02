class MoodEntry < ApplicationRecord
  belongs_to :user
  validates :date, presence: true
  validates :status, presence: true, inclusion: { in: 1..5 }
end
