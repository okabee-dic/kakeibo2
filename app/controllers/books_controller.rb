require "./app/services/books/get_receipts_list.rb"

class BooksController < ApplicationController
  include BooksHelper

  before_action :authenticate_user!, except: [:show]
  before_action :setting_id, only: [:edit, :update, :destroy, :get_balance, :show]
  before_action :your_book?, only: [:edit, :update, :destroy, :get_balance]
  before_action :books_params, only: [:create]

  def new
    @book = current_user.books.new
  end

  def create
    create_params = books_params
    unless create_params[:name].blank?
      book = current_user.books.new(create_params)
      book.save
      if book.persisted?
        # create default stores
        # デフォルトの店舗情報を追加
        Store::create_default(book.id)

        flash[:notice] = "家計簿を作成しました。"
        redirect_to edit_book_path(book.id)
      else
        @book = book
        flash[:alert] = "家計簿の作成に失敗しました。"
        redirect_to new_book_path and return
      end
    else
      redirect_to new_book_path and return
    end
  end

  def index
    @books = current_user.books.all.order("id")

    if @books.length == 0
      redirect_to new_book_path
    end
  end

  def destroy
    @book.destroy!
    redirect_to books_path
  end

  def edit
    # book/[bookid]/edit/[year]/[month]
    # setting month and year

    year, month = get_date()
    @year = year
    @month = month

    # get receipts
    my_receipts = GetReceiptsListService.new(@book.id, year, month).exec
    @receipts = my_receipts[:receipts]
    @incomes = my_receipts[:incomes]
    @total_receipts = price_to_string(my_receipts[:total_receipts])
    @total_incomes = price_to_string(my_receipts[:total_incomes])
    @total_result = price_to_string(my_receipts[:total_balance])

    @incomes.sort_by! { |income| income.pay_date.day }
    @receipts.sort_by! { |receipt| receipt.pay_date.day }

    @stores = @book.stores.all
  end

  def show
    # book/[bookid]/show/[year]/[month]
    # setting month and year

    year, month = get_date()
    @year = year
    @month = month

    # only on allow_show flag is enabled, exec this method.
    if @book.allow_show == false
      return redirect_to :root
    end

    # get receipts
    my_receipts = GetReceiptsListService.new(@book.id, year, month).exec
    @receipts = my_receipts[:receipts]
    @incomes = my_receipts[:incomes]
    @total_receipts = price_to_string(my_receipts[:total_receipts])
    @total_incomes = price_to_string(my_receipts[:total_incomes])
    @total_result = price_to_string(my_receipts[:total_balance])

    @incomes.sort_by! { |income| income.pay_date.day }
    @receipts.sort_by! { |receipt| receipt.pay_date.day }

    @stores = @book.stores.all

    render :template => "books/edit"
  end

  # update method is updating book's name
  def update
    name = params[:name]
    show_flag = params[:show_flag]

    if name == nil
      name = @book.name
    end
    if show_flag == nil
      show_flag = @book.allow_show
    end

    @book.update!({
      name: name,
      allow_show: show_flag,
    })

    result = {
      "name": name,
      "status": "OK",
    }
    render plain: result.to_json
  end

  # get_balance method is called when receipts are changed.
  # レシート情報が更新された際に呼ばれて収入と支出の情報を返す
  def get_balance
    target = params[:target] # receipts, incomes, balance, all

    year, month = get_date()

    #receipts_list = get_receipts_list(year, month)
    receipts_list = GetReceiptsListService.new(@book.id, year, month).exec

    if target == "receipts"
      render plain: receipts_list[:total_receipts]
    elsif target == "incomes"
      render plain: receipts_list[:total_incomes]
    elsif target == "balance"
      render plain: receipts_list[:total_balance]
    else
      result = {
        receipts: receipts_list[:total_receipts],
        incomes: receipts_list[:total_incomes],
        balance: receipts_list[:total_balance],
      }
      render plain: result.to_json
    end
  end

  protected

  def books_params
    result = params.require(:book).permit(:name, :show_flag)
    result
  end

  def setting_id
    @book_id = params[:id]
    @book = Book.find(@book_id)
  end

  def get_date
    today = Date.today
    year = today.year
    month = today.month

    if params[:month]
      month = params[:month].to_i
    end

    if params[:year]
      # year must be over 0
      if params[:year].to_i > 0
        year = params[:year].to_i
      else
        return redirect_to :root
      end
    end

    @showing_date = Date.new(year, month, 1)

    [year, month]
  end

  def price_to_string(price)
    # add ▲ when result is negative
    if price < 0
      result = "▲#{(-1 * price).to_s(:delimited)}"
    else
      result = price.to_s(:delimited)
    end

    result
  end
end
