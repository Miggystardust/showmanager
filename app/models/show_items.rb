class ShowItems
  include Mongoid::Document
   
  belongs_to :show

  validates_presence_of :kind, :act_id, :time
   
  field :kind, :type => String
  field :act_id, :type => String
  field :passet_id, :type => String
  field :time, :type => Time

  # extra note from the showadmin
  field :note, :type => String
  
end
