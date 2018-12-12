class Book < ApplicationRecord
  belongs_to :user, optional: true
  has_many :receipts, dependent: :destroy
  has_many :incomes, dependent: :destroy
  has_many :stores, dependent: :destroy
  has_many :monthlyinputs, dependent: :destroy
end
