class Donation < ApplicationRecord
  belongs_to :campaign

  enum :recurrence, {
    one_time: "one_time",
    monthly: "monthly"
  }, validate: true

  enum :display_preference, {
    full_name: "full_name",
    first_name: "first_name",
    anonymous: "anonymous"
  }, validate: true

  enum :status, {
    pending: "pending",
    paid: "paid"
  }, validate: true

  enum :dedication_type, {
    honor: "honor",
    memory: "memory"
  }, validate: { allow_nil: true }

  scope :counts_toward_progress, -> { where(status: [ statuses[:pending], statuses[:paid] ]) }

  validates :donor_email, presence: true
  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :donor_name, presence: true, unless: :anonymous?

  with_options if: :dedicated? do
    validates :dedication_honoree, presence: true
    validates :dedication_recipient_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :dedication_recipient_name, presence: true, if: :memory?
  end

  before_validation :clear_honor_recipient_name

  def anonymous?
    display_preference == "anonymous"
  end

  def dedicated?
    dedication_type.present?
  end

  def dedication_prefix
    return unless dedicated?

    memory? ? "לזכר" : "לכבוד"
  end

  def dedication_summary
    return unless dedicated? && dedication_honoree.present?

    "#{dedication_prefix} #{dedication_honoree}"
  end

  def display_name
    return "Anonymous" if anonymous?
    return donor_name.to_s.split.first if display_preference == "first_name"

    donor_name
  end

  private

  def clear_honor_recipient_name
    self.dedication_recipient_name = nil if honor?
  end
end
