 class Act
   # An Act that a user owns, comprised of many assets and people
   # possibly not part of this system.
   include Mongoid::Document

   belongs_to :user
   has_many :passets

   validates_presence_of :stage_name, :short_description, :length
   validates_numericality_of :length, :greater_than  => 0, :message => "Length must be in the form MM:SS and not be zero."

   # these fields required for part (1)
   field :stage_name, :type => String
   field :names_of_performers, :type => String
   field :contact_phone_number, :type => String
   field :length, :type => Integer     # length in seconds
   field :short_description, :type => String

   field :music, :type => String
   field :image, :type => String # image or video...

   field :sound_cue, :type => String
   field :prop_placement, :type => String

   field :lighting_info, :type => String
   field :clean_up, :type => String
   field :mc_intro, :type => String
   field :run_through, :type => String
   field :extra_notes, :type => String

   def length_s
     if self.length == nil
       "00:00"
     else
       m = (self.length/60).floor
       s = self.length % 60
       sprintf("%d:%2d",m,s)
     end
   end

   def music_s
     if self.music == nil
       return "Not specified"
     elsif self.music == "0"
       return "None"
     elsif self.music == "1"
       return "No Playback"
     else
       begin 
         p = Passet.find(self.music)
         if p
           if p.song_artist.blank? or p.song_title.blank?
             return p.filename
           else
             return "#{p.song_artist} - #{p.song_title}"
           end
         else
           return "Asset not found"
         end
       rescue Mongoid::Errors::DocumentNotFound
         return "Asset not found"
       end
     end
   end

   def image_s
     if self.image == nil
       return "Not specified"
     else
       if self.image == "0"
         return "None"
       end
       begin
         p = Passet.find(self.image)
         if p
           return p.filename
         else
           return "Asset not found"
         end
       rescue Mongoid::Errors::DocumentNotFound
         return "Asset not found"
       end
     end
   end


end
