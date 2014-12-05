class Show
   # A show, consisting of many show items...
   # essentially the spreadsheet joyce makes now.
   include Mongoid::Document

   belongs_to :troupe
   has_many :show_items
# jna: removing this for rails4 ? 
#   references_many :show_items, :dependent => :delete

   validates_presence_of :title
   validates_presence_of :show_time
   validates_presence_of :door_time
   validates_presence_of :venue
   validates_presence_of :troupe_id

   field :title, :type => String
   field :venue, :type => String

   field :show_time, :type => Time
   field :door_time, :type => Time

   # live show functions
   field :emergency_msg, :type => String
   field :highlighted_row, :type => String

   # an item is either an 'intermission' a 'note' or some shit.
end
