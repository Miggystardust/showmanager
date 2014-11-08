require 'fileutils'

class PassetsController <  ApplicationController

  protect_from_forgery :except => :create

  before_filter :authenticate_user!
  before_filter :verify_admin, :only => [:update, :edit, :adminindex]

  # this tends to explode on file upload, turning it off.
  skip_before_filter :verify_authenticity_token,  :only => [:new]

  def index
    @assets = current_user.passets.all.desc(:created_at)

    # TODO: portions of this code duplicate adminindex.
    # TODO: We are attempting for privilege separation here but i hate repeating code

    respond_to do | format|
      format.html { render :index }
      format.json {
        @filesarray = []
        @assets.each { |a|
          begin
            @u = User.find(a.created_by)
            userstring = "<a href=\"/users/#{a.created_by}\">#{@u.name}</a><BR><a href=\"mailto:#{@u.email}\">#{@u.email}</a>"
          rescue
            userstring = "<font color=\"#ff0000\">Deleted User</font>"
          end

          objectstring = embed_for(a)
          @filesarray << [ userstring, objectstring, a.to_html, a.id.to_s ]
        }
        render json: { 'aaData' => @filesarray }
      }
    end
  end

  def adminindex
    if current_user.try(:admin?)
      @assets = Passet.all.desc(:created_at)
      @adminindex = true
      respond_to do | format|
        format.html { render :index }
        format.json {
          @filesarray = []
          @assets.each { |a|
             begin
               @u = User.find(a.created_by)
               userstring = "<a href=\"/users/#{a.created_by}\">#{@u.name}</a><BR><a href=\"mailto:#{@u.email}\">#{@u.email}</a>"
             rescue
               userstring = "<font color=\"#ff0000\">Deleted User</font>"
             end
             objectstring = embed_for(a)

             @filesarray << [ userstring, objectstring, a.to_html, a.id.to_s ]
          }
          render json: { 'aaData' => @filesarray }
       }
      end
    else
      flash[:error] = "You must be an administrator to use that function."
      redirect_to "/"
    end
  end

  def new

  end

  def edit
    @passet = Passet.find(params[:id])
    @adminindex = true
  end

  def update
    @passet = Passet.find(params[:id])
    @passet.update_attributes(params[:passet])
    @passet.save!

    flash[:notice] = "Updated information for #{@passet.filename}"
    # only admins can ever do this, so go back there.
    redirect_to :action => :adminindex
  end

  def destroy
    # todo - ensure ownership here.
    p = Passet.find(params[:id])

    if p != nil
      logger.debug("Delete requested for Asset #{p.uuid}, #{request.referer}")
      p.destroy
      FileUtils.rm "#{UPLOADS_DIR}/#{p.uuid}"
    end

    if request.referer.match(/\/adminindex$/)
      redirect_to :action => :adminindex
    else
      redirect_to :action => :index
    end
  end

  def create
    # this id is used for tracking the current upload
    # TODO: remove external dependency here
    @uuid = `uuidgen`.strip

    if params[:files]
      tmp = params[:files][0].tempfile    
      logger.debug("Got file #{tmp.path}")
      filename = FileTools.sanitize_filename(params[:files][0].original_filename)
      fileinfo = determine_mime_type(filename)

      @file = "#{UPLOADS_DIR}/#{@uuid}"

      song_artist = ""
      song_title = ""
      song_length = 0
      song_bitrate = 0

      if fileinfo.match(/^audio\//)
        title = TagLib::MPEG::File.open(tmp.path) do |file|
          tag = file.tag
          prop = file.audio_properties
          song_artist = tag.artist
          song_title = tag.title
          song_length = prop.length
          song_bitrate = prop.bitrate
        end
      end

      logger.debug("Got: #{song_artist},#{song_title}")

      # TODO: Additional filename sanitization
      # TODO: Use md5 to find out if we've seen this before, don't allow dupes?

      # build the object
      @p = Passet.new(uuid: @uuid,
                    filename: filename,
                    kind: fileinfo,
                    created_at: Time.now(),
                    created_by: current_user.id,
                    song_artist: song_artist,
                    song_title: song_title,
                    song_length: song_length,
                    song_bitrate: song_bitrate
                    )
                        
      if @p.save
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
          "delete_url" => " /", 
          "delete_type" => "DELETE"
        }

        respond_to do |format| 
          format.html { 
            render layout: false
            render html: { files: [@response], status: :created  } 
          }
          format.json { 
            render json: { files: [@response], status: :created } 
          }
        end
      else 
        render :json => [{:error => "custom_failure"}], :status => 304
      end
    else
     logger.debug "Files array was blank"
    end
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

  private

  def embed_for(asset)
    if asset.is_audio?
     embed_html = "
      <audio src=\"/sf/" + asset.uuid + "\" controls=\"controls\" preload=\"none\">
         <object width=\"100\" height=\"30\" type=\"application/x-shockwave-flash\" data=\"/mejs/flashmediaelement.swf\">
         <param name=\"movie\" value=\"/mejs/flashmediaelement.swf\" />
         <param name=\"flashvars\" value=\"controls=true&file=/test.mp3\" />
         </object>
      </audio>
      "
    end

    if asset.is_image?
      embed_html = "<a id=\"single_image\" href=\"/sf/<%=passet.uuid%>.jpg\" rel=\"\">
       <IMG SRC=\"/s/" + asset.thumb_path(100,100) + "\" WIDTH=100 HEIGHT=100>\"</a>"
    end

    embed_html
  end

  def determine_mime_type(filename)
    ext = filename.split(".")[1].downcase()
    case ext
    when 'jpg'
      fileinfo = "image/jpeg"
    when 'jpeg'
      fileinfo = "image/jpeg"
    when 'png'
      fileinfo = "image/png"
    when 'gif'
      fileinfo = "image/gif"
    when 'mp3'
      fileinfo = "audio/mp3"
    when 'm4a'
      fileinfo = "audio/mp4"
    when 'mp4'
      fileinfo = "video/mp4"
    when 'm4v'
      fileinfo = "video/mp4"
    when 'mov'
      fileinfo = "video/quicktime"
    else
      fileinfo = "application/octet-stream"
    end
    fileinfo
  end

  def verify_admin
    if current_user.try(:admin?) == false
      flash[:error] = "You must be an administrator to use that function."
      redirect_to "/passets/"
    end
 end
end

