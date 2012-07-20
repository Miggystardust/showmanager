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
  
  # might use this.
  field :duration, :type => Integer
  field :time, :type => Time

  # extra note from the showadmin
  field :note, :type => String
  
end
