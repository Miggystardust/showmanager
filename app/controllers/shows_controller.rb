class ShowsController < ApplicationController
  protect_from_forgery

  before_filter :authenticate_user!
  before_filter do 
     redirect_to :new_user_session_path unless current_user && current_user.admin?
  end
   
  # GET /shows
  # GET /shows.json
  def index
    @shows = Show.all.desc(:door_time)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @shows }
    end
  end

  # GET /shows/1
  # GET /shows/1.json
  def show
    @show = Show.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @show }
    end
  end

  # GET /shows/new
  # GET /shows/new.json
  def new
    @show = Show.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @show }
    end
  end

  # GET /shows/1/edit
  def edit
    @show = Show.find(params[:id])
    @show_items = ShowItem.where(show_id: params[:id]) 

    # we keep one of these in reserve for the modal if it's needed.
    @show_item = ShowItem.new
  end

  # GET /shows/1/items
  def items
    @show_items = ShowItem.where(show_id: params[:id])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @show_items }
    end
  end

  # AJAX endpoint
  def show_items
    @show_items = ShowItem.where(show_id: params[:id])

    respond_to do |format|
      format.html { render :action => "index" }
      format.json { 
        # this format drives the show display index
        @si = []
        @show_items.each { |s|
          removeme = "<button class=\"btn btn-danger siremove\" id=\"#{s._id}\"><i class=\"icon-minus icon-white\"></i> Remove</button>"

          # seq, time, act data, duration, sound, light+stage, notes
          if s.kind != 0
            # this is an asset. 
            if s.act_id != 0
              act = Act.find(s.act_id)
            end
            
            if act == nil
              # something is seriously wrong. 
              actinfo = "<B>Cannot find Act ID #{s.act_id}, record #{s._id}</B>"
              @si << [s.seq,s.time,'--',0,'--','--',actinfo,'']
            else
              actinfo = "<B>#{act.stage_name}</B><BR>#{act.short_description}"

              @si << [s.seq,s.time,actinfo,act.length,act.sound_cue,"LIGHTS: #{act.lighting_info}<BR>STAGE: #{act.prop_placement}",act.extra_notes,removeme]
            end

          else
            # note
            @si << [s.seq,s.time,'--',0,'--','--',s.note,removeme]
          end
        }
        render json: { 'aaData' => @si }
      }
    end
  end

  # POST /shows
  # POST /shows.json
  def create
    @show = Show.new(params[:show])

    respond_to do |format|
    begin
      if @show.save
        format.html { redirect_to @show, notice: 'Show was successfully created.' }
        format.json { render json: @show, status: :created, location: @show }
      else
        format.html { render action: "new" }
        format.json { render json: @show.errors, status: :unprocessable_entity }
      end
    rescue Mongoid::Errors::InvalidTime
        flash[:error] = "Invalid Date Format."
    end
    end
  end

  # PUT /shows/1
  # PUT /shows/1.json
  def update
    @show = Show.find(params[:id])

    respond_to do |format|
      if @show.update_attributes(params[:show])
        format.html { redirect_to @show, notice: 'Show was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @show.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shows/1
  # DELETE /shows/1.json
  def destroy
    @show = Show.find(params[:id])
    @show.destroy

    respond_to do |format|
      format.html { redirect_to shows_url }
      format.json { head :no_content }
    end
  end
end
