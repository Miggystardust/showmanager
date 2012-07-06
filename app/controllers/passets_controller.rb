require 'fileutils'

class PassetsController <  ApplicationController
  
  protect_from_forgery

  before_filter :authenticate_user!
   
  def index
    @assets = current_user.passets.all
  end

  def destroy
    p = current_user.passets.find(params[:id])

    if p != nil
      logger.debug("Delete requestsed for Asset #{p.uuid}")
      p.destroy
      FileUtils.rm "#{UPLOADS_DIR}/#{p.uuid}"
    end
    redirect_to :action => :index
  end 

  def create
    if params[:file_upload][:my_file] == nil 
      flash[:error] = "You must specify a file to upload."
      redirect_to :action => :index
      return
    end

    tmp = params[:file_upload][:my_file].tempfile

    logger.debug("Got file #{tmp.path}")
    @uuid=`uuidgen`.strip
    fileinfo = `file #{tmp.path}`.strip
    
    @file = "#{UPLOADS_DIR}/#{@uuid}"
    
    # TODO: Only accept a limited number of extensions and types
    # mp3, mov, mp4, mp3, avi
    # block m4p (they are protected)
    # TODO: Additional filename sanitization
    # TODO: Use md5 to find out if we've seen this before, don't allow dupes?
    
    # build the object
    @p = Passet.new(uuid: @uuid, 
                    filename: FileTools.sanitize_filename(params[:file_upload][:my_file].original_filename), 
                    kind: fileinfo, 
                    sound_cue: params[:file_upload][:cue],	
                    light_cue: params[:file_upload][:cue],	
                    pnotes: params[:file_upload][:notes],
                    created_at: Time.now(),
                    created_by: current_user.actname)

    current_user.passets << @p
    
    # move it into place
    # TODO: Distribute data across directories
    logger.debug("copy #{tmp.path} to #{@file}")
    logger.debug("file is #{fileinfo}")
    FileUtils.cp tmp.path, @file
    FileUtils.rm tmp.path

    flash[:notice] = "Upload Ok! Thanks! Now add the file to your set."
    redirect_to :action => :index
  end

end
  
