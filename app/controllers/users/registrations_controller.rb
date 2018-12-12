# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]
  before_action :oauth_registration_params, only: [:oauth_registration]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    build_resource(sign_up_params)

    #binding.pry
    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
        #redirect_to users_send_confirm_path
      else
        #set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
        #redirect_to users_send_confirm_path
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end
  
  # if logined with OAuth, edit mypage without password
  def update_resource(resource, params)
    #if current_user.provider == "google"
    if resource.oauth?
      params.delete("current_password")
      resource.update_without_password(params)
    else
      resource.update_with_password(params)
    end
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end
  
  # check username is able to use.
  def username_check
    username = params[:username]
    myname = ''
    
    if current_user
      myname = current_user.username
    end
    
    #check validation
    testuser = User.new(
      username: username,
      email: '__anonymous@__self.com',
      uid: '__anonymoususer',
      provider: '__self'
    )
    testuser.valid?
    if testuser.errors.messages.has_key?(:username)
      message = 'invalid'
    end
    
    # check username exists
    if User.exists?( :username => username)
      if myname == username
        message = 'you'
      else
        message = 'exists'
      end
    else
      if message != 'invalid'
        message = 'available'
      end
    end
    
    result = {"message": message}.to_json
    
    render plain: result
  end
  
  def build_resource(hash={})
    hash[:uid] = User.create_unique_string
    super
  end
  
  #post username and nickname
  def oauth_registration
    kind = @param[:provider]
    if(kind == 'google')
      user = User.find_by(email: @param[:email] )
    end
    if(kind == 'facebook')
      user = User.find_by(provider: kind, uid: @param[:uid])
    end
    
    unless user
      user = User.new(email: @param[:email],
                    provider: @param[:provider],
                    uid:      @param[:uid],
                    sex:      @param[:sex],
                    username: @param[:username],
                    name:     @param[:name],
                    password: Devise.friendly_token[0, 20]
                                 )
      user.skip_confirmation!
      user.save
    end
    
    if user.persisted?
      sign_in_and_redirect user, event: :authentication
      set_flash_message(:notice, :success, kind: kind) if is_navigational_format?
    else
      #session['devise.google_data'] = request.env['omniauth.auth']
      @user = user
      flash[:notice] = '登録に失敗しましたので再入力をお願いします。'
      render :template => "devise/registrations/oauth"
    end
  end

  protected
  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end
  
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :username, :postcode, :prefecture_name, :address, :building, :sex, :telephone, :country, :corporatename])
  end 

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end
  
   def configure_account_update_params
     devise_parameter_sanitizer.permit(:account_update, keys: [:name, :email, :username, :postcode, :prefecture_name, :address, :building, :sex, :telephone, :country, :corporatename])
   end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    #super(resource)
    users_send_confirm_path
  end
   
  def oauth_registration_params
    @param = params.require(:user).permit(:username, :name, :uid, :email, :provider, :sex)
  end
end
