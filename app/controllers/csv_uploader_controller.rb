require 'csv'
require 'kconv'

class CsvUploaderController < ApplicationController
  include BooksHelper
  include ReceiptsHelper

  before_action :authenticate_user!
  before_action :setting_book_id
  before_action :your_book?

  def new

  end

  def create
    #params = uploader_params
    text = params[:upload_file].read
    #date = params[:date]
    year = params["date(1i)"].to_i
    month = params["date(2i)"].to_i   
    add_count = 0
    CSV.parse(Kconv.toutf8(text)) do |row|
      price = row[2].to_i
      pay_date = row[0].to_i
      
      if row.length >= 3    
        if( price < 0)
          #receipt
          store = find_store( row[1], false)
          writedata = {
            pay_date: Date.new(year, month, pay_date),
            price: -1*price ,
            store_id: store.id
          }
          receipt = @book.receipts.new(writedata)
          if receipt.save
            add_count = add_count + 1
          end
          a = 1

        elsif price == 0
          # do nothing
        else
          #income
          store = find_store( row[1], true)
          writedata = {
            pay_date: Date.new(year, month, pay_date),
            price: price.to_i ,
            store_id: store.id
          }

          income = @book.incomes.new(writedata)
          if income.save
            add_count = add_count + 1
          end
        end
      else
        # csv is too short
        # do nothing
      end  
    end
    # end add from csv
    if add_count > 0
      flash[:notice] = "CSVから#{add_count}個のデータを追加しました。"
    else
      flash[:notice] = "CSVは有効なファイルではありませんでした。"
    end

    redirect_to new_book_csv_uploader_path(@book_id)
  end

  private
  def uploader_params
    params.permit(:upload_file, :date)
  end
end
