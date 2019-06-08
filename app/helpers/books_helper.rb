module BooksHelper
  def setting_book_id
    @book_id = params[:book_id]
    @book = Book.find(@book_id)
  end

  def your_book?
    aaa = current_user
    unless @book.user_id == current_user.id
      unless current_user.admin == true
        return redirect_to :root
      end
    end
  end

  def make_date(year, month)
    result = []
    # get date
    month = Date.today.month
    year = Date.today.year
    month = month.to_i if month
    year = year.to_i if year
    binding.pry
    result[:showing_date] = Date.new(year, month, 1)
    result[:year] = year
    result[:month] = month
    result
  end
end
