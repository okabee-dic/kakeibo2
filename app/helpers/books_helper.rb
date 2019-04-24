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
end
