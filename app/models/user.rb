class User < ApplicationRecord
  normalizes :email_address, with: ->(e) { NormalizingHelper.normalize_email_address(e) }

  validates :email_address,
            presence: true,
            uniqueness: true,
            length: {
              minimum: 5,
              maximum: 255,
            },
            format: {
              with: RegexHelper::EMAIL_REGEX,
              message: "must be a valid email address",
            }

  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { maximum: 20 },
            format: {
              with: RegexHelper::USERNAME_REGEX,
              message: "can only contain letters, numbers, underscores, and periods, but cannot start with a number or contain consecutive underscores or periods",
            }

  has_many :sessions, dependent: :destroy
end
