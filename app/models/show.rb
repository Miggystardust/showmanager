class Show
   # A show, consisting of many show items...
   # essentially the spreadsheet joyce makes now.
   include Mongoid::Document

   has_many :show_items
   references_many :show_items, :dependent => :delete

   validates_presence_of :title
   validates_presence_of :show_time
   validates_presence_of :door_time
   validates_presence_of :venue

   field :title, :type => String
   field :venue, :type => String

   field :show_time, :type => Time
   field :door_time, :type => Time
   
   field :emergency_msg, :type => String
   # an item is either an 'intermission' a 'note' or some shit. 
end
