# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end
  
  def google
    @user = User.find_for_google(request.env['omniauth.auth'])
    
    # if user was not found, create new user. rendering the page to input username.
    if @user
      if @user.persisted?
        #binding.pry
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: "google") if is_navigational_format?
      else
        redirect_to new_user_registration_url
      end
    else
      auth = request.env['omniauth.auth']
      gender = auth[:extra][:raw_info].gender
      sex = 0
      if( gender == 'male')
        sex = 1
      end
      if( gender == 'female')
        sex = 2
      end
      #picture = auth.info.image
      @user = User.new(email: auth.info.email,
                    provider: auth.provider,
                    uid:      auth.uid,
                    sex:      sex,
                    password: Devise.friendly_token[0, 20]
                                 )
      render :template => "devise/registrations/oauth"
    end
  end
  
  def facebook
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)

    if @user
      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: "facebook") if is_navigational_format?
      else
        redirect_to new_user_registration_url
      end
    else
      auth = request.env['omniauth.auth']
      sex_of_user = 0
      
      if auth.provider == 'google'
        gender = auth[:extra][:raw_info].gender
        email_of_user = auth.email
        if( gender == 'male')
          sex_of_user = 1
        end
        if( gender == 'female')
          sex_of_user = 2
        end
        #picture_of_user = auth.info.image
      end
      
      if auth.provider == 'facebook'
        #picture_of_user = auth.info.image
        email_of_user = "#{auth.uid}-#{auth.provider}@example.com"
      end
      
      @user = User.new(email: email_of_user,
                    provider: auth.provider,
                    uid:      auth.uid,
                    sex:      sex_of_user,
                    password: Devise.friendly_token[0, 20]
                                 )
      render :template => "devise/registrations/oauth"
    end
  end

  # More info at:
  # https://github.com/plataformatec/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
