class Card < ApplicationRecord
  belongs_to :user
  has_many :transactions

  validates :number, presence: true, uniqueness: true
  validates :blocked, inclusion: { in: [true, false] }
end
