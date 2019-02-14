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

    # check new store name is unique in the book
    if @book.stores.where(:name => store_params[:name]).count > 0
      flash[:notice] = "店舗名は重複して設定できません。"
      return redirect_to book_stores_path(@book_id)
    end

    if store.update(store_params)
      flash[:notice] = "店舗情報の変更に成功しました。"
    else
      flash[:notice] = "店舗情報を変更できませんでした。"
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
