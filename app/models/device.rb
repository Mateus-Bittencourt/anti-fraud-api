class Device < ApplicationRecord
  belongs_to :user
  has_many :transactions

  validates :id, presence: true, uniqueness: true
  validates :blocked, inclusion: { in: [true, false] }
end
