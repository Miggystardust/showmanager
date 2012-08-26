class Troupe
  include Mongoid::Document
  has_many :users

  field :troupe_name, :type => String
  field :description, :type => String

end
