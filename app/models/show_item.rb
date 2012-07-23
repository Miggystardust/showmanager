class ShowItem
  include Mongoid::Document
   
  belongs_to :show

  validates_presence_of :kind, :act_id

  # 0 = note
  # 32 = asset
  field :kind, :type => Integer

  # sequence in this show
  field :seq, :type => Integer

  # act_id is zero if note.
  field :act_id, :type => String
  
  # The way we handle times is as follows:
  #
  # if a time is set here, we use it, That's a 'fixed' time reference. 
  # else 
  #   if this is an asset, we use the duratio n from the asset.
  #   else 
  #   this is a note, use the duration from here
  #
  field :duration, :type => Integer
  field :time, :type => Time

  # extra note from the showadmin
  field :note, :type => String
  
end
