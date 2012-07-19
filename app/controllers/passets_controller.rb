require 'fileutils'

class PassetsController <  ApplicationController
  
  protect_from_forgery

  before_filter :authenticate_user!
   
  def index
    @assets = current_user.passets.all.desc(:created_at)
  end

  def adminindex
    if current_user.try(:admin?) 
      @assets = Passet.all.desc(:created_at)
      @adminindex = true
      render :index
    else 
      flash[:error] = "You must be an administrator to use that function."
      redirect_to "/"
    end
  end

  def new

  end

  def edit
    @passet = current_user.passets.find(params[:id])
  end

  def update
    @passet = current_user.passets.find(params[:id])
    @passet.update_attributes(notes: params[:passet][:notes])
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
    if params[:files] == nil 
      flash[:error] = "You must specify a file to upload."
      redirect_to :action => :new
      @response = {"error" => "No Files specified"}
      render :json => [@response].to_json
    end

    # this id is used for tracking the current upload
    @uuid = `uuidgen`.strip

    tmp = params[:files][0].tempfile

    logger.debug("Got file #{tmp.path}")
    fileinfo = `file --mime #{tmp.path}`.strip.split[1].gsub(";","")
    filename = FileTools.sanitize_filename(params[:files][0].original_filename)

    @file = "#{UPLOADS_DIR}/#{@uuid}"

    # TODO: Additional filename sanitization
    # TODO: Use md5 to find out if we've seen this before, don't allow dupes?
    
    # build the object
    @p = Passet.new(uuid: @uuid, 
                    filename: filename,
                    kind: fileinfo, 
                    created_at: Time.now(),
                    created_by: current_user.id)

    current_user.passets << @p
    
    # move it into place
    # TODO: Distribute data across directories
    FileUtils.cp tmp.path, @file
    fsize = File.size(tmp.path)
    FileUtils.rm tmp.path

    logger.debug("copy #{tmp.path} to #{@file} size = #{fsize}")

    @response = {
      "name" => filename,
      "size" => fsize,
      "url" => "/sf/#{@p.uuid}",
      "thumbnail_url" => @p.icon,
      "delete_url" => " /", #picture_path(:id => id),
      "delete_type" => "DELETE"
    }

    render :json => [@response].to_json
  end

  def search
    return [] if params[:term].blank?
    query = params[:term]

    # normalize here
    assets = Passet.any_of({filename: /#{query}/i}, {created_by: /#{query}/i}).asc(:filename).limit(10)

    list = assets.map do |i|
      { label: "#{i.created_by}: #{i.filename} (#{i.kind})", id: i.uuid } 
    end
    
    # and specials... "INTERMISSION:" etc... 

    render :json => list
  end
     

end
  
