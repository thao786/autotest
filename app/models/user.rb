class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :suites
  has_many :templates

  devise :omniauthable, omniauth_providers: [:google_oauth2]

  before_create :set_defaults
  def set_defaults
    self.language = 'ruby'
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first

    # Uncomment the section below if you want users to be created if they don't exist
    unless user
        user = User.create(name: data['name'],
           email: data['email'],
           password: Devise.friendly_token[0,20],
           provider: access_token.provider,
           uid: access_token.uid,
           image: data['image']
        )
    end
    user
  end
end
