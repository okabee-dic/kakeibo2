class Store < ApplicationRecord
  belongs_to :book, optional: true

  def self.create_default(book_id)
    book = Book.find(book_id)
    binding.pry
    genre_id = Genre.find_by(:income => false).id
    store = book.stores.create({
      name: "支出",
      genre_id: genre_id,
      is_income: false,
      locked: true,
    })
    # default income
    genre_id = Genre.find_by(:income => true).id
    store = book.stores.create({
      name: "収入",
      genre_id: genre_id,
      is_income: true,
      locked: true,
    })
  end
end
