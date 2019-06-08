require "./app/services/books/get_receipts_list.rb"

class GraphsController < ApplicationController
  include BooksHelper
  before_action :setting_book_id

  def index
    redirect_to linegraph_book_graphs_path(@book_id)
  end

  def linegraph
    # data array for linegraph
    gon.labels = []
    gon.spends = []
    gon.incomes = []
    gon.totals = []

    @number_of_monthes = 12

    date_array = make_date(params[:year], params[:month])
    @year = date_array[:year]
    @month = date_array[:month]
    @showing_date = date_array[:showing_date]

    graphdata = get_graphdata(@number_of_monthes, @showing_date)

    # reverse data and input to gon
    for i in 0..@number_of_monthes
      gon.incomes << graphdata[:incomes_array][@number_of_monthes - i]
      gon.spends << graphdata[:spends_array][@number_of_monthes - i]
      gon.totals << graphdata[:totals][@number_of_monthes - i]
      gon.labels << graphdata[:months][@number_of_monthes - i]
    end
  end

  private

  def get_graphdata(number_of_monthes, showing_date)
    spends_array = []
    incomes_array = []
    totals = []
    years = []
    months = []

    for i in 0..number_of_monthes
      i_date = showing_date.prev_month(i)
      year = i_date.year
      month = i_date.month
      years.push(year)
      months.push(month)

      my_receipts = GetReceiptsListService.new(@book.id, year, month).exec

      spends_array.push(my_receipts[:total_receipts])
      incomes_array.push(my_receipts[:total_incomes])
      totals.push(my_receipts[:total_balance])
    end

    # create result
    result = {
      spends_array: spends_array,
      incomes_array: incomes_array,
      totals: totals,
      years: years,
      months: months,
    }

    result
  end
end
