class Role
  include Mongoid::Document

  field :name, :type => String
  field :description, :type => String

# jna: remove for rails4
#  attr_accessible :name, :description

# jna: removing for rails4
#  references_and_referenced_in_many :users
end


