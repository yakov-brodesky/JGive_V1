class Campaign < ApplicationRecord
  belongs_to :organization
  has_many :donations, dependent: :destroy
  has_many :donation_options, dependent: :destroy

  validates :title, :subtitle, :story, :currency, presence: true
  validates :goal_amount_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :baseline_raised_amount_cents,
    :baseline_donor_count,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def raised_amount_cents
    baseline_raised_amount_cents + progress_donations.sum(:amount_cents)
  end

  def total_donor_count
    baseline_donor_count + progress_donations.count
  end

  def progress_percentage
    return 0 if goal_amount_cents.zero?

    ((raised_amount_cents.to_f / goal_amount_cents) * 100).round
  end

  private

  def progress_donations
    donations.counts_toward_progress
  end
end
