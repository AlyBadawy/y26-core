class SleepHoursEntry < ApplicationRecord
  belongs_to :user
  validates :date, presence: true
  validates :hours, presence: true, inclusion: { in: 0..10 }
end
