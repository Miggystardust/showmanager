class Troupe
  include Mongoid::Document

  belongs_to :user
  has_many :troupe_memberships

  validates_presence_of :name, :description

  field :name, :type => String
  field :description, :type => String
  field :private, :type => Boolean, :default => false

  #
  # careful here; Troupe.users = users that belong to the troupe.
  # Troupe.user_id = user who owns troupe.
  #
  def users
    User.in(id: troupe_memberships.map(&:user_id))
  end

end
