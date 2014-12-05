class Invitation
  include Mongoid::Document
  include Mongoid::Timestamps

  validates_presence_of :troupe_id
  validates_presence_of :type
  before_create :generate_token

  # 0 = troupe invitation (user to user)
  # 1 = troupe invitation (user to email)

  belongs_to :sender, :class_name => "User"
  has_one :recipient, :class_name => "User"

  field :type, :type => Integer, :default => 1
  field :email, :type => String
  field :troupe_id
  field :valid_until, :type => DateTime

  field :token, :type => String

  private

  def generate_token
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end
  
end
