class ShowItems
  include Mongoid::Document
   
  belongs_to :show

  validates_presence_of :kind
  validates_presence_of :cue_id
 
  field :kind, :type => String
  field :cue_id, :type => String

  # extra note from the showadmin
  field :note, :type => String
  
end
