module ReceiptsHelper
  def find_store(store_name, is_income)
      
    if @book.stores.exists?(:name => store_name, :is_income => is_income)
      return @book.stores.find_by(:name => store_name, :is_income => is_income)
    else
      # add new store
      genre_id = Genre.where(:income => is_income).first.id
      
      store = @book.stores.new({
        name: store_name,
        genre_id: genre_id,
        is_income: is_income
      })
      
      store.save
      return store
    end
  end
  
  def get_result_on_succeed(data, input)
    result = {}
    result[:pay_date] = data[:pay_date]
    result[:price] = data[:price]
    result[:store_name] = input[:store_name]
    result[:type] = input[:type]
    result[:row_id] = input[:row_id]
    result[:id] = data[:id]

    result[:html] = render_to_string :partial => "books/receipt_row", :locals => 
      { receipt: data, type: result[:type] }

    result
  end
  
  def get_params_to_hash
    input = {}
    input[:pay_date] = params[:pay_date].to_i.abs
    input[:store_name] = params[:store]
    input[:price] = params[:price].to_i.abs
    input[:type] = params[:type]
    input[:year] = params[:year].to_i.abs
    input[:month] = params[:month].to_i.abs
    input[:row_id] = params[:row_id].to_i

    # validate date
    unless Date.valid_date?(input[:year], input[:month], input[:pay_date])
      input[:pay_date] = 1 if input[:pay_date] < 0
      # if over the last day of the month, then day is the last day.
      input[:pay_date] = -1 if input[:pay_date] > 1
    end

    input
  end
end
