require "csv"
require "kconv"

class CsvUploaderController < ApplicationController
  include BooksHelper
  include ReceiptsHelper

  before_action :authenticate_user!
  before_action :setting_book_id
  before_action :your_book?

  def new
  end

  def create
    text = params[:upload_file].read
    year = params["date(1i)"].to_i
    month = params["date(2i)"].to_i
    add_count = 0
    is_multimode = false
    CSV.parse(Kconv.toutf8(text)) do |row|
      # if first row is "kakeibo_csv", then multi-monthes mode.
      # 最初の文字列が"kakeibo_csv"なら、複数月をまとめて入力する
      if (row[0] == "kakeibo_csv")
        is_multimode = true
        next
      end

      store_name = ""

      # input to variables
      unless is_multimode
        price = row[2].to_i
        pay_date = row[0].to_i
        store_name = row[1]
      else
        price = row[4].to_i
        pay_date = row[2].to_i
        store_name = row[3]
        month = row[1].to_i
        year = row[0].to_i
        # year must be over 0
        if year <= 0
          year = nil
        end
      end

      binding.pry

      # data check
      if price == nil || pay_date == nil || store_name == nil || year == nil || month == nil
        next
      end
      if pay_date == 0 || month == 0
        next
      end

      if row.length >= 3
        if (price < 0)
          #receipt
          store = find_store(store_name, false)
          date = Date.new(year, month, pay_date)
          if date == nil
            next
          end
          writedata = {
            pay_date: date,
            price: -1 * price,
            store_id: store.id,
          }
          receipt = @book.receipts.new(writedata)
          if receipt.save
            add_count = add_count + 1
          end
        elsif price == 0
          # do nothing
        else
          #income
          store = find_store(store_name, true)
          date = Date.new(year, month, pay_date)
          if date == nil
            next
          end
          writedata = {
            pay_date: date,
            price: price,
            store_id: store.id,
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
