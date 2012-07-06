class UploadsController < ApplicationController 
  protect_from_forgery

  before_filter :authenticate_user!

  def download
    # todo: saniize fn
    fn = params["fn"]
    logger.debug fn 
    send_file "#{UPLOADS_DIR}/#{fn}", :type=>"audio/mpeg"
  end
  
end
