class MonthlyinputsController < ApplicationController
  include BooksHelper
    
  before_action :authenticate_user!
  before_action :setting_book_id
  before_action :your_book?
  
  def index
    @monthlyinputs = @book.monthlyinputs.order('id')
    @input = @book.monthlyinputs.new
  end
  
  def create
    create_params = monthlyinput_params
    
    # if end date was before start date
    if create_params[:invalid?]
      @input = Monthlyinput.new
      @monthlyinputs = @book.monthlyinputs.order('id')
      flash.now[:alert] = '終了日は開始日よりも後の日付にしてください。'
      render :action => :index  
      return
    end
      
    monthlyinput = @book.monthlyinputs.new(create_params)
    
    if monthlyinput.save
      flash[:notice] = '毎月ごとの自動入力を追加しました。'
    else
      flash[:notice] = '毎月ごとの自動入力の追加に失敗しました。'
    end
    
    redirect_to book_monthlyinputs_path(@book_id)
  end
  
  def update
    monthlyinput = Monthlyinput.find(params[:id])
    
    update_params = monthlyinput_params
    
    # if end date was before start date
    if update_params[:invalid?]
      @input = Monthlyinput.new(update_params)
      @monthlyinputs = @book.monthlyinputs.order('id')
      flash.now[:alert] = '終了日は開始日よりも後の日付にしてください。'
      render :action => :index  
      return
    end
    
    if monthlyinput.update(update_params)
      flash[:notice] = '毎月ごとの自動入力を変更しました。'
    else
      flash[:notice] = '毎月ごとの自動入力の変更に失敗しました。'
    end
    
    redirect_to book_monthlyinputs_path(@book_id)
  end
  
  def destroy
    monthlyinput = Monthlyinput.find(params[:id])
    
    if monthlyinput.destroy
      flash[:notice] = '毎月ごとの自動入力を削除しました。'
    else
      flash[:notice] = '毎月ごとの自動入力の削除に失敗しました。'
    end
    
    redirect_to book_monthlyinputs_path(@book_id)
  end
  
  protected
  
  def monthlyinput_params
    result = params.require('monthlyinput').permit(:name, :pay_date, :price, :store_id, :start_date, :end_date)
    result[:pay_date] = check_paydate(result[:pay_date])
    
    # if end date was before start date, show error
    monthlyinput = Monthlyinput.new(result)
    if monthlyinput[:start_date] > monthlyinput[:end_date]
      result[:invalid?] = true
    end

    # setting is_income flag
    result[:is_income] = Store.find(result[:store_id]).is_income
    
    result
  end
  
  def check_paydate(day)
    result = day.to_i
    if result < 1
      result = 1
    end
    if result > 31
      result = 31 
    end
    result
  end
end
