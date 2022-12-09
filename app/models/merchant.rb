class Merchant < ApplicationRecord
  has_many :transactions
  has_many :users, through: :transactions
  validates :merchant_id, presence: true, uniqueness: true
end
