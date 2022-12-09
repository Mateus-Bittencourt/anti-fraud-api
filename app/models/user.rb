class User < ApplicationRecord
  has_many :cards
  has_many :transactions
  has_many :devices
  has_many :merchants, through: :transactions
  validates :user_id, presence: true, uniqueness: true
  # validates :score, presence: true,
  #                   numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
  # validates :chargeback_block, presence: true
end
