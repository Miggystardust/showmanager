 class Act
   # An Act that a user owns, comprised of many assets and people
   # possibly not part of this system.
   include Mongoid::Document

   belongs_to :user
   has_many :passets

   before_validation :length_to_seconds

   validates_presence_of :stage_name, :short_description, :length

   field :stage_name, :type => String
   field :names_of_performers, :type => String
   field :contact_phone_number, :type => String
   field :length, :type => Integer     # length in minutes
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
     end
   end

   def image_s
     if self.image == nil
       return "Not specified"
     else
       if self.image == "0"
         return "None"
       end

       p = Passet.find(self.image)
       if p
         return p.filename
       else
         return "Asset not found"
       end
     end
   end

   def length_to_seconds
     if self.length == nil
       # we'll let rails complain about this for us.
       return
     end

     if self.length.is_a?(Fixnum)
       return
     end

     if self.length.is_a?(Float)
       errors.add(:act,"Length must be in the form MM:SS. Do not enter lengths with decimal points.")
       return
     end

     if self.length.match(/\A\d+:\d+\z/)
       p = self.length.split(":")

       if p[1].to_i > 59
         errors.add(:act,"Length must be in the form MM:SS")
         return
       end

       t = (p[0].to_i * 60) + p[1].to_i

       self.length = t
     else
       errors.add(:act,"Length must be in the form MM:SS")
     end
   end

end
