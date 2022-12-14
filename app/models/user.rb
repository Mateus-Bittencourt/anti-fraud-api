class User < ApplicationRecord
  has_many :cards
  has_many :transactions
  has_many :devices
  has_many :merchants, through: :transactions
  validates :id, presence: true, uniqueness: true
  validates :blocked, inclusion: { in: [true, false] }
  validates :chargeback_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }


end
