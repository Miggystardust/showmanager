class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  has_many :acts
  has_many :passets
  has_many :troupes
  has_many :apps

  # Role-Based Access Control
# removing for rails4 ? 
#  references_and_referenced_in_many :roles

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  ## OmniAuth Integration
  field :provider,           :type => String, :default => ""
  field :uid,                :type => String, :default => ""

  validates_presence_of :email
  validates_presence_of :encrypted_password

  field :phone_number,       :type => String, :default => ""

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  field :username, :type => String

  field :admin, :type => Boolean, :default => false

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String
  # run 'rake db:mongoid:create_indexes' to create indexes

  index( { username: 1 }, { unique: true })
  index( { email: 1 }, { unique: true })

  field :name

  validates_presence_of :name
  validates_presence_of :username

  def has_role?(role_sym)
    roles.each { |r|
      if r.name.underscore.to_sym == role_sym
        return true
      end
    }
    false
  end

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    logger.debug("find for fb :provider => #{auth.provider}, :uid => #{auth.uid}")
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      logger.debug("need to create.")
      user = User.create(username:auth.extra.raw_info.name.clone,
                         name:auth.extra.raw_info.name,
                         provider:auth.provider,
                         uid:auth.uid,
                         email:auth.info.email,
                         password:Devise.friendly_token[0,20]
                         )
      user.save!
    end
    user
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end


end
