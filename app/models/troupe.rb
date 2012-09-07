class Troupe
  include Mongoid::Document

  belongs_to :user

  validates_presence_of :name, :description, :private

  field :name, :type => String
  field :description, :type => String
  field :private, :type => Boolean
end
