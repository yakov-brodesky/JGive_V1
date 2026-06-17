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

  scope :counts_toward_progress, -> { where(status: [ statuses[:pending], statuses[:paid] ]) }

  validates :donor_email, presence: true
  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :donor_name, presence: true, unless: :anonymous?

  def anonymous?
    display_preference == "anonymous"
  end

  def display_name
    return "Anonymous" if anonymous?
    return donor_name.to_s.split.first if display_preference == "first_name"

    donor_name
  end
end
