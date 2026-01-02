class MoodEntry < ApplicationRecord
  belongs_to :user
  validates :date, presence: true
  validates :date, uniqueness: { scope: :user_id }
  validates :status, presence: true, inclusion: { in: 1..5 }
end
