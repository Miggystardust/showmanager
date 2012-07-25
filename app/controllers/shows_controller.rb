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
    @show_items = ShowItem.where(show_id: params[:id]) 

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
    @show_items = ShowItem.where(show_id: params[:id]).asc(:seq)
    @show = Show.find(params[:id])
    
    itemtime = @show.door_time
    respond_to do |format|
      format.html { render :action => "index" }
      format.json { 
        # this format drives the show display index
        @si = []
        @show_items.each { |s|
          removeme = "<button class=\"btn btn-danger btn-small siremove\" id=\"#{s._id}\"><i class=\"icon-minus icon-white\"></i> Remove</button> "
          editact = "<button class=\"btn btn-warning btn-small editact\" id=\"#{s._id}\"><i class=\"icon-share-alt icon-white\"></i> Edit Act</button>" 
          # seq, time, act data, sound, light+stage, notes
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

              sound = ""
              if act.music != ""
                if act.music != 0 
                  p = Passet.where(_id:act.music)[0]
                  if p
                    if p.song_artist != ""
                      sound = sound + "<B>#{p.song_artist}</B><BR>"
                    end
                    if p.song_title != ""
                      sound = sound + "<EM>#{p.song_title}</EM><BR>"
                    end
                    # If we have no tags, then use the filename.
                    sound = sound + "#{p.filename}<BR>"
                  else
                    sound = "None<BR>"
                  end
                end
              else
                sound = "Not Specified<BR>"
              end

              if act.sound_cue == ""
                sound = sound + "<B>CUE:</B> Not specified"
              else
                sound = sound + "<B>CUE:</B> #{act.sound_cue}"
              end
              
              # build the stage instructions from all the fields
              stage = ""
              
              if act.mc_intro != ""
                stage += "<B>MC INTRO:</B> #{act.mc_intro}<BR>"
              end
              
              if act.image != "" and act.image != '0'
                p = Passet.where(_id:act.image)[0]
                if p
                  stage += "<B>IMAGE:</B> #{p.filename}<BR>"
                else
                  stage += "<B>IMAGE:</B> <font color=\"#ff0000\">Image not on file</font><BR>"
                end                
              end
              
              if act.lighting_info != ""
                stage += "<B>LIGHTS:</B> #{act.lighting_info}<BR>"
              end
              
              if act.prop_placement != ""
                stage += "<B>STAGE:</B> #{act.prop_placement}<BR>"
              end
              
              if act.clean_up != ""
                stage += "<B>CLEANUP:</B> #{act.clean_up}<BR>"
              end

              @si << { "DT_RowId" => s._id,
                "0" => s.seq,
                "1" => itemtime.strftime("%l:%M %P"),
                "2" => actinfo,
                "3" => sound,
                "4" => stage,
                "5" => act.extra_notes,
                "6" => removeme + editact,
              }
              
              logger.debug("add act with length #{act.length}")
              if act.length != nil
                  itemtime = itemtime + (act.length * 60)
              end
            end

          else
            # note
            @si << { "DT_RowId" => s._id,
              "0" => s.seq,
              "1" => itemtime.strftime("%l:%M %P"),
              "2" => "--",
              "3" => "--",
              "4" => "--",
              "5" => "<B>" + s.note + "</B>",
              "6" => removeme,
            }
            logger.debug("add note with length #{s.duration} #{s}")
            
            if s.duration != nil
                itemtime = itemtime + (s.duration * 60)
            end
          end

        }
        render json: { 'iTotalRecords' => @si.length, 'aaData' => @si }
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
    @show_items = ShowItem.where(show_id: params[:id]) 
    @show_item = ShowItem.new

    respond_to do |format|
      if @show.update_attributes(params[:show])
        format.html { redirect_to "/shows/#{@show.id}/edit", notice: 'Show details were successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to "/shows/#{@show.id}/edit"}
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
