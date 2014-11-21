class TroupeMembership
  include Mongoid::Document

  # has_many_through style table showing what users belong to what troupes

  belongs_to :user
  belongs_to :troupe

end