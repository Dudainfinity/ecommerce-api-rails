class User < ApplicationRecord
  has_secure_password

  enum :role, { customer: 0, admin: 1 }

  has_many :orders, dependent: :destroy

  before_validation :normalize_email

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { password.present? }

  private

  def normalize_email
    self.email = email.to_s.downcase.strip
  end
end
