class ImagesController < ActionController::Base
  
  # for development use, serve thumbs via ruby. We'd normally route
  # these via apache
  def servethumb
    fn = "#{THUMBS_DIR}/" + FileTools.sanitize_filename(params[:uuid]) + "-" + FileTools.sanitize_filename(params[:dims]) + ".jpg"

    logger.debug "serve: #{fn}, uuid: #{params[:uuid]}"

    if File.exist?(fn) == false 
      @image = Passet.where({:uuid => params["uuid"]})[0]
      if @image == nil
        raise ActionController::RoutingError.new('Image Not Found (srv)')
      end

      width, height = params[:dims].scan(/\d+/).map(&:to_i)
      @image.thumbnail!(width, height)
    end

    send_file "#{fn}", :type=>"image/jpeg", :x_sendfile=>true
  end
  
end
