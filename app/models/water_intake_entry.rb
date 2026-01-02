class WaterIntakeEntry < ApplicationRecord
  belongs_to :user
  validates :date, presence: true
  validates :date, uniqueness: { scope: :user_id }
  validates :cups, presence: true, inclusion: { in: 1..10 }
end
