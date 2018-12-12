class IncomesController < ApplicationController
  include BooksHelper
  include ReceiptsHelper
  
  before_action :authenticate_user!
  before_action :setting_book_id
  before_action :your_book?
    
  def create
    input = get_params_to_hash
    
    store = find_store(input[:store_name], true)
    unless store.persisted?
      return render plain: 'error_store_data'
    end
    
    writedata = {
      pay_date: Date.new(input[:year], input[:month], input[:pay_date]),
      price: input[:price],
      store_id: store.id
    }
    
    newdata = @book.incomes.new(writedata)
    
    if newdata.save
      return render plain: get_result_on_succeed(newdata, input).to_json
    else
      return render plain: 'error_write_data'
    end
  end
  
  def update
    input = get_params_to_hash
    
    # find store
    store = find_store(input[:store_name], true)
    unless store.persisted?
      return render plain: 'error_store_data'
    end
    
    row = @book.incomes.find(params[:id])
    
    update_data = {
      pay_date: Date.new(input[:year], input[:month], input[:pay_date]),
      price: input[:price],
      store_id: store.id 
    }
    
    if row.update(update_data)
      render plain: get_result_on_succeed(row, input).to_json
    else
      render plain: 'error_write_data'
    end
  end
  
  def destroy
    row = @book.incomes.find(params[:id])
    
    result = {}
    result[:row_id] = params[:row_id]
    result[:type] = params[:type]
    
    if row.destroy
      render plain: result.to_json
    else
      render plain: 'error_delete'
    end
  end
end
