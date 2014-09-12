
class ShowsController < ApplicationController
  protect_from_forgery

  include ApplicationHelper

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
      format.json {
        # drive datatables
        @showarray = []
        @shows.each { |show|
            @showarray << [show.title, show.venue, show.door_time.strftime(SHORT_TIME_FMT), show.show_time.strftime(SHORT_TIME_FMT),show._id.to_s]
        }
        render json: { 'aaData' => @showarray }
      }
    end
  end

  # GET /shows/1/perfindex...
  # this is list of all performers in this show, for the setlist. 
  def perfindex
    @show = Show.find(params[:id])
    @show_items = ShowItem.where(show_id: params[:id]).asc(:seq)
    @si_act = Hash.new

    # prefetch the acts in this show
    @show_items.each{ |si|
      act = nil
      begin
        if si.kind != 0
          # this is an asset.
          if si.act_id != 0
            act = Act.find(si.act_id)
          end
        end
        @si_act[si.act_id] = act
      rescue
        # this act is not part of the show and therefore, we do not add it. 
        @si_act[si.act_id] = nil
      end
    }
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

  def download
    # create a zip file of an entire show.
    @show_items = ShowItem.where(show_id: params[:id]).asc(:seq)
    @show = Show.find(params[:id])
    @filelist = Hash.new

    @safe_title = @show.title.gsub(" ","_")
    @safe_title = @safe_title.gsub("\\","")
    @safe_title = @safe_title.gsub(")","")
    @safe_title = @safe_title.gsub("(","")
    @safe_title = @safe_title.gsub("'","")
    @safe_title = @safe_title.gsub("`","")
    @safe_title = @safe_title.gsub(";","")
    @safe_title = @safe_title.gsub(":","")

    @stat_acts = 0
    @stat_music = 0
    @stat_images = 0

    @show_items.each { |s|
      begin
        a = Act.find(s.act_id)
        if a
          @stat_acts += 1

          p = Passet.find(a.music)
          @filelist[p.uuid] = p.filename
          @stat_music += 1

          p = Passet.find(a.image)
          @filelist[p.uuid] = p.filename
          @stat_images += 1
        end
      rescue BSON::InvalidObjectId, Mongoid::Errors::DocumentNotFound
        # there is a record associated with this show which doesn't exist anymore.

        # we silently skip the item if we can't locate the act or if the
        # ID in question is invalid (i.e. 0 or 1)
      end
    }

    # what follows is a series of disgusting system calls.
    logexec("mkdir #{Rails.root}/tmp/#{@safe_title}")

    seq = 0

    @filelist.each_pair do |id,fn|
      seq = seq + 1

      # poor sanitization here.
      fn = fn.gsub(" ","_")
      fn = fn.gsub("\\","")
      fn = fn.gsub(")","")
      fn = fn.gsub("(","")
      fn = fn.gsub("'","")
      fn = fn.gsub("`","")
      fn = fn.gsub(";","")
      fn = fn.gsub(":","")

      logexec("cp #{UPLOADS_DIR}/#{id} #{Rails.root}/tmp/#{@safe_title}/#{sprintf("%02d",seq)}_#{fn}")
    end

    # make sure our zipdir is there.
    begin
      File.stat("#{Rails.root}/public/zips")
    rescue Errno::ENOENT
      logexec("mkdir #{Rails.root}/public/zips")
    end

    logexec("cd #{Rails.root}/tmp; zip -9 -r #{@safe_title}.zip #{@safe_title}")
    logexec("mv #{Rails.root}/tmp/#{@safe_title}.zip #{Rails.root}/public/zips")
    logexec("rm -rf #{Rails.root}/tmp/#{@safe_title}")

    @zipstat = File.stat("#{Rails.root}/public/zips/#{@safe_title}.zip")
    @zipfile = "/zips/#{@safe_title}.zip"
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
          # menus are built based on a number of items and we must provide them over Ajax to datatables
          markact = ""
          editact = ""
          editdur = ""
          removeme = ""
          moveme = ""

          if params[:m] == nil
            moveme = "<button class=\"btn btn-inverse btn-mini moveup\" id=\"#{s._id.to_s}\"><i class=\"icon-arrow-up icon-white\"></i></button>&nbsp;<button class=\"btn btn-inverse btn-mini movedown\" id=\"#{s._id.to_s}\"><i class=\"icon-arrow-down icon-white\"></i></button>&nbsp;"
            removeme = "<button class=\"btn btn-danger btn-mini siremove\" id=\"#{s._id.to_s}\"><i class=\"icon-trash icon-white\"></i></button>&nbsp;"
            editact = "<button class=\"btn btn-success btn-mini editact\" id=\"#{s.act_id.to_s}\"><i class=\"icon-pencil icon-white\"></i></button>&nbsp;"
            editdur = "<button class=\"btn btn-info btn-mini editduration\" id=\"#{s._id.to_s}\"><i class=\"icon-time icon-white\"></i></button>&nbsp;"
          else
            if s.id.to_s == @show.highlighted_row.to_s
              markact = "<button class=\"btn btn-info btn-mini noprint unmarkitem\" id=\"#{s._id.to_s}\"><i class=\"icon-ban-circle icon-white\"></i> Unmark</button>&nbsp;"
            else
              markact = "<button class=\"btn btn-info btn-mini noprint markitem\" id=\"#{s._id.to_s}\"><i class=\"icon-flag icon-white\"></i> Mark</button>&nbsp;"
            end
          end

          # seq, time, act data, sound, light+stage, notes
          if s.kind != 0
            # this is an asset.
            if s.act_id != 0
              begin
                act = Act.find(s.act_id)
              rescue Mongoid::Errors::DocumentNotFound
                act = nil
              end
            end

            if act == nil
              # something is seriously wrong.
              actinfo = "<B>Cannot find Act ID #{s.act_id.to_s}, record #{s._id.to_s}</B>"
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

              @si << { "DT_RowId" => s._id.to_s,
                "0" => s.seq,
                "1" => "#{itemtime.strftime("%l:%M %P")}<BR>+#{sec_to_time(s.duration.to_i)}",
                "2" => actinfo,
                "3" => sound,
                "4" => stage,
                "5" => act.extra_notes,
                "6" => moveme + removeme + editact + editdur + markact
              }

              if s.duration != nil
                  itemtime = itemtime + s.duration.to_i
              end
            end

          else
            # note
            @si << { "DT_RowId" => s._id.to_s,
              "0" => s.seq,
              "1" => "#{itemtime.strftime("%l:%M %P")}<BR>+#{sec_to_time(s.duration.to_i)}",
              "2" => "--",
              "3" => "--",
              "4" => "--",
              "5" => "<B>" + s.note + "</B>",
              "6" => moveme + removeme + editdur + markact 
            }

            if s.duration != nil
                itemtime = itemtime + s.duration.to_i
            end
          end

        }
        render json: { 'iTotalRecords' => @si.length, 'aaData' => @si, 'highlighted' => @show.highlighted_row }
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

  private

  def logexec(command)
    r = system(command)
    logger.info("#{command} / result=#{r}")
  end

end
