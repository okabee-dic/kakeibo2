class GraphsController < ApplicationController
  include BooksHelper
  before_action :setting_book_id

  def index
    redirect_to linegraph_book_graphs_path(@book_id)
  end

  def linegraph
    years = []
    months = []
    spends_array = []
    incomes_array = []
    totals = []
    gon.labels = []
    gon.spends = []
    gon.incomes = []
    gon.totals = []

    @month = Date.today.month
    @year =  Date.today.year
    if params[:month]
      @month = params[:month].to_i
    end
    if params[:year]
      @year = params[:year].to_i
    end
    showing_date = Date.new(@year, @month, 1)
    @showing_date = showing_date
    
    # get 10 months data
    for i in 0..10
      i_date = showing_date.prev_month(i+1)
      year = i_date.year
      month = i_date.month
      years.push(year)
      months.push(month)
      month_start = Date.new(year, month, 1)
      month_end   = Date.new(year, month, -1)

      incomes = @book.incomes.where("pay_date >= ? and pay_date <= ?", month_start, month_end)
      receipts = @book.receipts.where("pay_date >= ? and pay_date <= ?", month_start, month_end)
      monthlyinputs = @book.monthlyinputs.where("start_date <= ? and end_date >= ?", 
                      month_start, month_start)
                    
      incomes_total =  incomes.sum('price')
      receipts_total = receipts.sum('price')
      monthlyinputs.each do |m|
        if m.is_income == true
          incomes_total = incomes_total + m.price
        else
          receipts_total = receipts_total + m.price
        end
      end
      
      spends_array.push(receipts_total)
      incomes_array.push(incomes_total)
      totals.push(incomes_total - receipts_total)
    end
    
    # reverse data
    for i in 0..10
      gon.incomes << incomes_array[10-i]
      gon.spends << spends_array[10-i]
      gon.totals << totals[10-i]
      gon.labels << months[10-i] 
    end
  end
end
