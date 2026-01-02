class SleepHoursEntry < ApplicationRecord
  belongs_to :user
  validates :date, presence: true
  validates :date, uniqueness: { scope: :user_id }
  validates :hours, presence: true, inclusion: { in: 0..10 }
end
