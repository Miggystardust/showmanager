class ImagesController < ActionController::Base
  
  def serve
    @image = Passet.where({:uuid => params["uuid"]})[0]
    if @image == nil
      raise ActionController::RoutingError.new('Image Not Found')
    end

    width, height = params[:dims].scan(/\d+/).map(&:to_i)
    @image.thumbnail!(width, height)

    redirect_to(@image.thumb_path(width, height))
  end

  # for development use, serve thumbs via ruby. We'd normally route
  # these via apache
  def servethumb
    fn = "#{THUMBS_DIR}/" + FileTools.sanitize_filename(params[:uuid]) + "-" + FileTools.sanitize_filename(params[:dims]) + ".jpg"
    logger.debug("serve: #{fn}")

    if File.exist?(fn) == false 
      raise ActionController::RoutingError.new('Image Not Found')
    else 
      send_file "#{fn}", :type=>"image/jpeg", :x_sendfile=>true
    end
  end
  
end
