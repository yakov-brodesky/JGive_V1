class DonationOption < ApplicationRecord
  belongs_to :campaign
  has_many :donations, dependent: :nullify

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :id) }

  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :label, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
