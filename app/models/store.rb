class Store < ApplicationRecord
  belongs_to :book, optional: true
end
