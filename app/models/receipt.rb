class Receipt < ApplicationRecord
  belongs_to :book, optional: true
end
