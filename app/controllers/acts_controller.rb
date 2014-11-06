class ActsController < ApplicationController
  include ApplicationHelper

  protect_from_forgery
#  load_and_authorize_resource

  before_filter :authenticate_user!
  before_filter :set_cache_buster
  before_filter :build_user_selects, :except => [ :destroy ]

  def build_user_selects
    # we build this every pass because we use them in most operations
    @user_imgs = [['None',0]]
    @user_musics = [['None',0],["-- band or single performer, no playback --",1]]

    if current_user.try(:admin?)
      # admins get to see everything.
      ui = Passet.where(kind: /^image\//).order_by(filename: 1)
      um = Passet.where(kind: /^audio\//).order_by(filename: 1)
      ua = Passet.where(kind: /^application\/octet-stream$/).order_by(filename: 0) # ew!
    else
      ui = current_user.passets.where(kind: /^image\//).order_by(filename: 1)
      um = current_user.passets.where(kind: /^audio\//).order_by(filename: 1)
      ua = current_user.passets.where(kind: /^application\/octet-stream$/).order_by(filename: 0)
    end

    ui.each do |u|
      @user_imgs << [u.filename,u.id]
    end

    um.each do |u|
      name = u.filename

      if u.song_title and u.song_artist
        if not u.song_title.blank? and not u.song_artist.blank?
          name = "#{u.filename}: #{u.song_artist} / #{u.song_title}"
        end
      end

      @user_musics << [name,u.id]
    end

    # stuff these in music I guess.
    # not really sure what to do here.
    ua.each do |u|
      @user_musics << [u.filename,u.id]
    end

  end

  # GET /acts
  # GET /acts.json
  def index
    # TODO: This routine breaks if you request /acts/self.  The logic is inverted and needs help.
    #       admin access should not change this thing's output. admin should be moved to /adminindex or
    #       similar
    if current_user.admin then
      logger.info "acts: loading for admin"
      # an admin can request "latest" acts, which gives only the latest acts per performer.
      # the dirty hack here is to reverse-sort by id, to give 'latest', and then to only
      # append it to the array if it's not the same as the last id we appended. O(n). boo.
      if params[:latest] == 'true' then
        logger.info "acts: loading latest only"
        @acts = []
        @origacts = Act.desc(:user_id, :_id)
        lastuid = nil

        @origacts.each { |a|
          if a.user_id != lastuid then
            @acts << a
          end
          lastuid = a.user_id
        }
      else
        @acts = Act.all
      end
      @showowner = true
    else
      logger.info "acts: loading for non admin or self"
      logger.info current_user.acts
    end

    respond_to do |format|
      format.html { render :action => "index" }
      format.json {
        # this format is used to drive the show editing page. It is a digusting O(n) query. I do not care.
        # talk to me when we have 100k users.
        @actarray = []
        @acts.each { |a|
          un = "<font color=#ff0000>Deleted User</font>"

          if a.user != nil
            un = a.user.name + "<br>" + a.user.email
          end

          # get asset details if any
          musicinfo = ""
          if a.music != '0' and a.music != '1' and a.music != nil
            p = Passet.where(_id:a.music)[0]
            if p != nil
              if not p.song_artist.blank? and not p.song_title.blank?
                musicinfo = "#{p.song_artist} - #{p.song_title}"
              else
                musicinfo = p.filename
              end

              if p.song_length > 0
                  musicinfo = "#{musicinfo} (#{sec_to_mmss(p.song_length)})"
              end
            end
          end

          # TODO: REFACTOR, move the button code to the view.
          # type 1 is the add-to-showpage which shows an add button
          # type 2 is standard index. which shows the owner and edit/update buttons
          if params[:type].to_i == 2
            @actarray << [un, a.stage_name, a.short_description + " (" + sec_to_time(a.length) + ")", musicinfo,
                          "<a class=\"btn btn-mini btn-success\" href=\"/acts/#{a._id}/edit\" id=\"#{a._id}\"><i class=\"glyphicon glyphicon-pencil white\"></i> Edit</a>&nbsp;<a class=\"btn btn-mini btn-danger\" href=\"/acts/#{a._id}\" data-confirm=\"Are you sure?\" data-method=\"delete\" rel=\"nofollow\"><i class=\"glyphicon glyphicon-remove white\"></i> Delete</a>",
                         ]
          else
            @actarray << [un, a.stage_name, a.short_description + " (" + sec_to_time(a.length) + ")", musicinfo, a.id.generation_time.getlocal.strftime(SHORT_TIME_FMT), "<button class=\"btn btn-success actadder\" id=\"#{a._id}\"><i class=\"glyphicon glyphicon-plus white\"></i> Add</button>"]
          end
        }
        render json: { 'aaData' => @actarray }
      }
    end

  end

  # GET /acts/1
  # GET /acts/1.json
  def show
    @act = Act.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @act }
    end
  end

  # GET /acts/new
  # GET /acts/new.json
  def new
    @act = Act.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @act }
    end
  end

  # GET /acts/1/edit
  def edit
    @act = Act.find(params[:id])

    if @act.user_id != current_user.id and current_user.try(:admin?) == false
      flash[:error] = "You don't own that Act."
      redirect_to "/acts"
    end

    @act.length = sec_to_mmss(@act.length)
    @return_to=""

    if params[:return_to]
      if params[:return_to].match(/\A[0-9a-f]+\z/)
        @return_to = params[:return_to]
      end
    end
  end

  # POST /acts
  # POST /acts.json
  def create
    @act = Act.new(params[:act])

    #jna: removing for rails4, not sure what this adds.
    #current_user.passets.where()

    respond_to do |format|
      if @act.save
        current_user.acts << @act
        current_user.save!

        format.html { redirect_to "/acts", notice: 'Act was successfully created.' }
        format.json { render json: @act, status: :created, location: @act }
      else
        format.html { render action: "new" }
        format.json { render json: @act.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /acts/1
  # PUT /acts/1.json
  def update
    @act = Act.find(params[:id])

    if params[:return_to]
      if params[:return_to].match(/\A[0-9a-f]+\z/)
        @return_to = params[:return_to]
      end
    end

    respond_to do |format|
      if @act.update_attributes(params[:act])
        format.html {
          if @return_to
            redirect_to "/shows/#{@return_to}/edit", notice: 'Act was successfully updated.'
            return
          end
          redirect_to "/acts", notice: 'Act was successfully updated.'
        }

        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @act.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /acts/1
  # DELETE /acts/1.json
  def destroy
    @act = Act.find(params[:id])
    @act.destroy

    respond_to do |format|
      format.html {
        if request.referer and request.referer.match(/\/adminindex$/)
          redirect_to :action => :adminindex
        else
          redirect_to :action => :index
        end
      }

      format.json { head :no_content }
    end
  end
end
