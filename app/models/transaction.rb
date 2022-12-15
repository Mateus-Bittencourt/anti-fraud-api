class Transaction < ApplicationRecord
  belongs_to :merchant
  belongs_to :user
  belongs_to :device, optional: true
  belongs_to :card

  validates :id, presence: true, uniqueness: true
  validates :date, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :recommendation, presence: true, inclusion: { in: %w[approve deny] }
  validates :chargeback, inclusion: { in: [true, false] }
end
