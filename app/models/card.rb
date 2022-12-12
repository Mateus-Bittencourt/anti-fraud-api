class Card < ApplicationRecord
  belongs_to :user
  has_many :transactions


  validates :card_number, presence: true, uniqueness: true
end
