module ReceiptsHelper
  def find_store(store_name, is_income)
      
    if @book.stores.exists?(:name => store_name)
      return @book.stores.find_by(:name => store_name)
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
    result
  end
  
  def get_params_to_hash
    input = {}
    input[:pay_date] = params[:pay_date].to_i
    input[:store_name] = params[:store]
    input[:price] = params[:price].to_i
    input[:type] = params[:type]
    input[:year] = params[:year].to_i
    input[:month] = params[:month].to_i
    input[:row_id] = params[:row_id].to_i
    input
  end
end
