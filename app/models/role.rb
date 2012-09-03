class Role
  include Mongoid::Document

  field :name, :type => String
  field :description, :type => String

  attr_accessible :name, :description

  references_and_referenced_in_many :users
end


