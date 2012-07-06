class Passet
   # individual assets assigned to a user 
   include Mongoid::Document

   belongs_to :user

   field :created_at => DateTime
   field :created_by => String

   field :uuid, :type => String
   field :filename, :type => String
   field :kind, :type => String
   field :notes, :type => String
   
   # You can leave +height+ blank if you like.
   def thumb_path(w, h = nil)
      h ||= width / aspect_ratio
      "#{uuid}-#{w.to_i}x#{h.to_i}.jpg"
   end

   # Where to store images in the filesystem when they
   # are created.
   def image_path(w, h = nil)
     "#{THUMBS_DIR}/#{thumb_path(w, h)}"
   end

   # Generate thumbnail from the original image
   def thumbnail!(w, h)
     logger.debug("#{UPLOADS_DIR}/#{uuid} ---> #{image_path(w,h)} thumbnail create")
     ImageTools.thumbnail("#{UPLOADS_DIR}/#{uuid}", image_path(w,h), w.to_i, h.to_i)
   end
     
end
