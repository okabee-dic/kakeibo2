class StoresController < ApplicationController
  include BooksHelper

  before_action :authenticate_user!
  before_action :setting_book_id
  before_action :your_book?

  def index
    @stores = @book.stores.order("numbering, id")
  end

  def create
    store = @book.stores.new(store_params)

    if store.save
      flash[:notice] = "店舗の追加に成功しました。"
    else
      flash[:notice] = "店舗の追加に失敗しました。"
    end

    redirect_to book_stores_path(@book_id)
  end

  def update
    store = Store.find(params[:id])

    update_data = store_params

    # check new store name is unique in the book
    if @book.stores.where(:name => update_data[:name], :genre_id => update_data[:genre_id]).count > 0
      flash[:notice] = "店舗名は重複して設定できません。"
      return redirect_to book_stores_path(@book_id)
    end

    # notice message
    message_success = "店舗情報の変更に成功しました。"
    message_fail = "店舗情報を変更できませんでした。"

    # check locked flag, only change numbering parameter.
    if store[:locked]
      update_data[:name] = store[:name]
      update_data[:genre_id] = store[:genre_id]
      update_data[:is_income] = store[:is_income]
      message_success = "ロックされている店舗情報は表示順のみ変えることができます。"
    end

    # is_income data is automatic setting from genre_id
    #if update_data[:genre_id] != store[:genre_id]
    #  update_data[:is_income] = Genre.find(update_data[:genre_id]).income
    #end

    # is_income must not be changed.
    update_data[:is_income] = store[:is_income]

    if store.update(update_data)
      flash[:notice] = message_success
    else
      flash[:notice] = message_fail
    end

    redirect_to book_stores_path(@book_id)
  end

  def destroy
    store = Store.find(params[:id])

    # cannot delete the store that the locked flag is setted
    if store.locked == true
      flash[:error] = "削除不可の店舗情報を削除しようとしたため、中止されました。"
      return redirect_to book_stores_path(@book_id)
    end

    # if the store is setted in any books, set another store
    alter_store = @book.stores.where(:locked => true, :is_income => store.is_income).first

    if store.is_income == true
      receipt_table = @book.incomes
    else
      receipt_table = @book.receipts
    end
    receipt_table.where(:store_id => store.id).find_each do |receipt|
      receipt.update({store_id: alter_store.id})
    end

    # deleting the store
    if store.destroy
      flash[:notice] = "店舗情報を削除しました。"
    else
      flash[:notice] = "店舗情報を削除できませんでした。"
    end

    redirect_to book_stores_path(@book_id)
  end

  protected

  def store_params
    result = params.require(:store).permit(:name, :genre_id, :numbering, :is_income)
    if params[:store][:is_income] == "2"
      genre = Genre.find(result[:genre_id])
      result[:is_income] = genre[:income]
    end
    result
  end
end
