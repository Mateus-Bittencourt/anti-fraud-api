class Transaction < ApplicationRecord
  belongs_to :merchant
  belongs_to :user
  belongs_to :device, optional: true
  has_one :card
  validates :transaction_id, presence: true, uniqueness: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  # validates :score, presence: true,
  #                   numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
  # validates :chargeback, presence: true
  validates :recommendation, presence: true, inclusion: { in: %w[approve deny] }
  validates :transaction_date, presence: true
end
