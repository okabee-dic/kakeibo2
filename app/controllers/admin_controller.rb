class AdminController < ApplicationController
  before_action :check_admin
  before_action :genre_params, only: [:genre_add, :genre_update]
  
  def genres
    @genres = Genre.all
  end
  
  def genre_add
    genre = Genre.new(@params)
    
    if genre.save
      flash[:notice] = 'ジャンル追加に成功しました'
    else
      flash[:notice] = 'ジャンル追加に失敗しました。'
    end  
    redirect_to admin_genres_path
  end
  
  def genre_destroy
    genre = Genre.find(params[:id])
    
    genre.destroy
    
    flash[:notice] = 'ジャンルを削除しました。'
    
    redirect_to admin_genres_path
  end
  
  def genre_update
    genre = Genre.find(params[:id])
    
    if genre.update(@params)
      flash[:notice] = 'ジャンルを編集しました。'
    else
      flash[:notice] = 'ジャンルの編集に失敗しました。' 
    end
    
    redirect_to admin_genres_path
  end
  
  protected
  
  def check_admin
    if user_signed_in?
      if current_user.admin == false
        return redirect_to :root
      end
    else
      return redirect_to :root
    end
  end
  
  def genre_params
    @params = params.require('genre').permit(:name, :income, :convinience, :supermarket, :eatout,
                                             :runningcost, :other, :unearned, :earning)
  end
end
