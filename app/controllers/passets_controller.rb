require 'fileutils'

class PassetsController <  ApplicationController
  
  protect_from_forgery

  before_filter :authenticate_user!
   
  def index
    @assets = current_user.passets.all.desc(:created_at)
  end

  def new
    # just show 
  end

  def edit
    @passet = current_user.passets.find(params[:id])
  end

  def update
    @passet = current_user.passets.find(params[:id])
    @passet.update_attributes(
                              notes: params[:passet][:notes],
                              sound_cue: params[:passet][:sound_cue],
                              light_cue: params[:passet][:light_cue])
    @passet.save!

    flash[:notice] = "Updated information for #{@passet.filename}"
    redirect_to :action => :index
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
    fileinfo = `file --mime #{tmp.path}`.strip.split[1].gsub(";","")

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
                    sound_cue: params[:file_upload][:sound_cue],	
                    light_cue: params[:file_upload][:light_cue],	
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
  
