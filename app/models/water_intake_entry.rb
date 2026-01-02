class WaterIntakeEntry < ApplicationRecord
  belongs_to :user
  validates :date, presence: true
  validates :cups, presence: true, inclusion: { in: 1..10 }
end
