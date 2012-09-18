class Troupe
  include Mongoid::Document

  belongs_to :user

  validates_presence_of :name, :description

  field :name, :type => String
  field :description, :type => String
  field :private, :type => Boolean, :default => false

end
