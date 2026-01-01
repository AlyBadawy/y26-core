class WeatherEntry < ApplicationRecord
  belongs_to :user

  validates :date, presence: true, uniqueness: { scope: :user_id }
  validates :status, presence: true, inclusion: { in: %w[sun cloud cloudSun cloudRain cloudSnow zap] }


  enum :status, {
    sun: "sun",
    cloud: "cloud",
    cloudSun: "cloudSun",
    cloudRain: "cloudRain",
    cloudSnow: "cloudSnow",
    zap: "zap",
    }
end
