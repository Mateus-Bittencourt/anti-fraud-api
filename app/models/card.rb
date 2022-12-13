class Card < ApplicationRecord
  belongs_to :user
  has_many :transactions


  validates :number, presence: true, uniqueness: true
end
