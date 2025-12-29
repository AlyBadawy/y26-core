module NormalizingHelper
  extend self

  def normalize_email_address(email)
    email.to_s.strip.downcase
  end
end
