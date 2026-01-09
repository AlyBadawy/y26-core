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

  validates :password,
            length: {
              minimum: AuthConfiguration.password_min_length,
              maximum: AuthConfiguration.password_max_length,
            },
            format: {
              with: AuthConfiguration.password_complexity,
              message: "must contain at least one uppercase letter, one lowercase letter, one digit, and one special character",
            },
            allow_blank: true

      validates :password_confirmation,
                presence: true,
                if: -> { password.present? }

  has_secure_password

  has_many :sessions, dependent: :destroy

  has_many :weather_entries, dependent: :destroy
  has_many :mood_entries, dependent: :destroy
  has_many :water_intake_entries, dependent: :destroy
  has_many :sleep_hours_entries, dependent: :destroy
  has_many :affirmation_entries, dependent: :destroy
  has_many :gratitude_entries, dependent: :destroy
  has_many :journal_entries, dependent: :destroy

  has_many :books, dependent: :destroy
  has_many :movies, dependent: :destroy

  before_save :update_password_changed_at, if: :will_save_change_to_password_digest?

  def generate_reset_password_token!
    update!(
      reset_password_token: TokenGenerator.generate_password_reset_token,
      reset_password_token_created_at: Time.current
    )
  end

  def reset_password_token_valid?
    return false if reset_password_token.blank? || reset_password_token_created_at.blank?

    duration = AuthConfiguration.password_expires_in
    return false unless duration.is_a?(ActiveSupport::Duration)

    reset_password_token_created_at > duration.ago
  end

  def clear_reset_password_token!
    update!(
      reset_password_token: nil,
      reset_password_token_created_at: nil
    )
  end

  def password_expired?
    return false unless AuthConfiguration.password_expires
    return true unless password_changed_at

    password_changed_at < AuthConfiguration.password_expires_in.ago
  end

  private

  def update_password_changed_at
    self.password_changed_at = Time.current
  end
end
