class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable,
         :omniauthable, omniauth_providers: %i(google facebook),
         authentication_keys: [:login]
         
  include JpPrefecture
  jp_prefecture :prefecture_code
  
  def prefecture_name
    JpPrefecture::Prefecture.find(code: prefecture_id).try(:name)
  end
  
  def prefecture_name=(prefecture_name)
    self.prefecture_id = JpPrefecture::Prefecture.find(name: prefecture_name).code
  end
  
  validates :username,
    uniqueness: { case_sensitive: :false },
    length: { minimum: 4, maximum: 20 },
    format: { with: /\A[a-z0-9_-]+\z/, message: "ユーザー名は半角英数字です"}
    # usernameにxxx@xxx.comのようにメールアドレスが入ってしまうとどちらかわからなくなるので、@は入ってはならない。
    
  has_many :books, dependent: :destroy
    
  attr_writer :login

  def login
    @login || self.username || self.email
  end
  
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end
  
  def self.create_unique_string
    SecureRandom.uuid
  end
  
  def self.oauth?
    if self.provider == ''
      false
    else
      true
    end
  end
  
  def self.find_for_google(auth)
    user = User.find_by(email: auth.info.email)
    user
  end
  
  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.find_by(provider: auth.provider, uid: auth.uid)
    user
  end
  
end
