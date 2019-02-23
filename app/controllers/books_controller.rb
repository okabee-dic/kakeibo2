class BooksController < ApplicationController
  include BooksHelper
  
  before_action :authenticate_user!, except: [:show]
  before_action :setting_id, only: [:edit, :update, :destroy, :get_balance]
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
        # default receipt
        genre_id = Genre.find_by( :income => false).id
        store = book.stores.create({
          name: '支出',
          genre_id: genre_id,
          is_income: false,
          locked: true
        })
        # default income
        genre_id = Genre.find_by( :income => true).id
        store = book.stores.create({
          name: '収入',
          genre_id: genre_id,
          is_income: true,
          locked: true
        })
        
        flash[:notice] = '家計簿を作成しました。'
        redirect_to edit_book_path(book.id)
      else
        @book = book
        flash[:alert] = '家計簿の作成に失敗しました。'
        redirect_to new_book_path and return
      end
    else
      redirect_to new_book_path and return
    end
  end
  
  def index
    @books = current_user.books.all.order('id')
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
    monthlyinputs = @book.monthlyinputs.where("start_date <= ? and end_date >= ?", showing_start, showing_start)
    
    @incomes  = []
    @receipts = []

    # total result of incomes/receipts
    @total_receipts = 0;
    @total_incomes = 0;
    
    # add monthly inputs
    monthlyinputs.each do |m| 
      #if m.start_date <= today && m.end_date >= today
        new_input = {
          store_id: m.store_id,
          price: m.price,
          pay_date: Date.new(year, month ,m.pay_date)
        }
        
        if m.is_income == true
          data = @book.incomes.new(new_input)
          @incomes.push( data )
          @total_incomes = @total_incomes + m.price
        else
          data = @book.receipts.new(new_input)
          @receipts.push( data )
          @total_receipts = @total_receipts + m.price
        end
      #end  
    end

    # add incomes
    incomes.each do |income|
      @incomes.push(income)
      @total_incomes = @total_incomes + income.price
    end
    
    #add receipts
    receipts.each do |receipt|
      @receipts.push(receipt)
      @total_receipts = @total_receipts + receipt.price
    end
    
    @incomes.sort_by! {|income| income.pay_date.day}
    @receipts.sort_by! {|receipt| receipt.pay_date.day}

    @total_result = (@total_incomes - @total_receipts)
    @total_receipts = @total_receipts.to_s(:delimited)
    @total_incomes = @total_incomes.to_s(:delimited)

    if @total_result < 0
      @total_result = "▲#{ (-1*@total_result).to_s(:delimited) }"
    else
      @total_result = @total_result.to_s(:delimited)
    end
    
    @stores = @book.stores.all
    @year = year
    @month = month
  end
  
  def update
    name = params[:name]
    @book.update!({
      name: name
    })   

    result = {
      "name": name,
      "status": "OK"
    }
    render plain: result.to_json
  end

  def get_balance
    month = params[:month].to_i
    year = params[:year].to_i
    target = params[:target] # receipts, incomes, balance, all

    month = Date.today.month if month == nil
    year = Date.today.year if year == nil

    receipts_list = get_receipts_list(year, month)

    if target == 'receipts'
      render plain: receipts_list[:total_receipts]
    elsif target == 'incomes'
      render plain: receipts_list[:total_incomes]
    elsif target == 'balance'
      render plain: receipts_list[:total_balance]
    else
      result = {
        receipts: receipts_list[:total_receipts],
        incomes: receipts_list[:total_incomes],
        balance: receipts_list[:total_balance]
      }
      render plain: result.to_json
    end
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

  def get_receipts_list(year, month)
    # need @book
    showing_start = Date.new(year, month, 1)
    showing_end   = Date.new(year, month, -1)
    @showing_date = showing_start
    
    incomes = @book.incomes.where("pay_date >= ? and pay_date <= ?", showing_start, showing_end)
    receipts = @book.receipts.where("pay_date >= ? and pay_date <= ?", showing_start, showing_end)
    monthlyinputs = @book.monthlyinputs.where("start_date <= ? and end_date >= ?", showing_start, showing_start)
    
    incomes_array  = []
    receipts_array = []

    # total result of incomes/receipts
    total_receipts = 0;
    total_incomes = 0;
    
    # add monthly inputs
    monthlyinputs.each do |m| 
      #if m.start_date <= today && m.end_date >= today
        new_input = {
          store_id: m.store_id,
          price: m.price,
          pay_date: Date.new(year, month ,m.pay_date)
        }
        
        if m.is_income == true
          data = @book.incomes.new(new_input)
          incomes_array.push( data )
          total_incomes = total_incomes + m.price
        else
          data = @book.receipts.new(new_input)
          receipts_array.push( data )
          total_receipts = total_receipts + m.price
        end
      #end  
    end

    # add incomes
    incomes.each do |income|
      incomes_array.push(income)
      total_incomes = total_incomes + income.price
    end
    
    #add receipts
    receipts.each do |receipt|
      receipts_array.push(receipt)
      total_receipts = total_receipts + receipt.price
    end

    total_balance = (total_incomes - total_receipts)
    
    result = {
      total_balance: total_balance,
      total_incomes: total_incomes,
      total_receipts: total_receipts,
      incomes: incomes_array,
      receipts: receipts_array
    }
    
    result
  end
end
