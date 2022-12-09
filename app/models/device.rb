class Device < ApplicationRecord
  belongs_to :user
  has_many :transactions
  validates :device_id, presence: true, uniqueness: true
end
