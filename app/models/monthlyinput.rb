class Monthlyinput < ApplicationRecord
  belongs_to :books, optional: true
end
