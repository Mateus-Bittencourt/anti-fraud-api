class Card < ApplicationRecord
  belongs_to :user
  validates :card_number, presence: true, uniqueness: true
end
