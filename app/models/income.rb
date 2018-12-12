class Income < ApplicationRecord
  belongs_to :book, optional: true
end
