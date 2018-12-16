class BooksController < ApplicationController
  include BooksHelper
  
  before_action :authenticate_user!, except: [:show]
  before_action :setting_id, only: [:edit, :update, :destroy]
  before_action :your_book?, only: [:edit, :update, :destroy]
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
        # default receipt
        genre_id = Genre.find_by( :is_income => false).id
        store = book.stores.create({
          name: '支出',
          genre_id: genre_id,
          is_income: false
        })
        # default income
        genre_id = Genre.find_by( :is_income => true).id
        store = book.stores.create({
          name: '収入',
          genre_id: genre_id,
          is_income: true
        })
        
        flash[:notice] = '家計簿を作成しました。'
        redirect_to edit_book_path(book.id)
      else
        @book = book
        flash[:alert] = '家計簿の作成に失敗しました。'
        redirect_to new_book_path
      end
    else
      redirect_to new_book_path
    end
  end
  
  def index
    @books = current_user.books.all
  end
  
  def destroy
    @book.destroy!
    redirect_to books_path
  end
  
  def edit
    # setting month and year
    today = Date.today
    year  = today.year
    month = today.month
    
    if params[:month]
      month = params[:month].to_i
    end
    
    if params[:year]
      year = params[:year].to_i
    end
    
    showing_start = Date.new(year, month, 1)
    showing_end   = Date.new(year, month, -1)
    @showing_date = showing_start
    
    incomes = @book.incomes.where("pay_date >= ? and pay_date <= ?", showing_start, showing_end)
    receipts = @book.receipts.where("pay_date >= ? and pay_date <= ?", showing_start, showing_end)
    monthlyinputs = @book.monthlyinputs.where("start_date >= ? and end_date <= ?", showing_start, showing_start)
    
    @incomes  = []
    @receipts = []
    
    # add monthly inputs
    monthlyinputs.each do |m| 
      #if m.start_date <= today && m.end_date >= today
        new_input = {
          store_id: m.store_id,
          price: m.price,
          pay_date: Date.new(year, month ,m.pay_date)
        }
        
        if m.is_income == true
          @incomes.push( @book.incomes.new(new_input) )
        else
          @receipts.push( @book.receipts.new(new_input) )
        end
      #end  
    end
    
    # add incomes
    incomes.each do |income|
      @incomes.push(income)
    end
    
    #add receipts
    receipts.each do |receipt|
      @receipts.push(receipt)
    end
    
    @incomes.sort_by! {|income| income.pay_date.day}
    @receipts.sort_by! {|receipt| receipt.pay_date.day}
    
    @stores = @book.stores.all
    @year = year
    @month = month
  end
  
  def update
  
  end
  
  protected 
  
  def books_params
    result = params.require(:book).permit(:name)
    result
  end
  
  def setting_id
    @book_id = params[:id]
    @book = Book.find(@book_id)
  end
end
