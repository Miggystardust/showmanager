class EntryTechinfosController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_cache_buster
  
  before_action :set_entry_techinfo, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!

  # GET /entry_techinfos
  def index
    @entry_techinfos = EntryTechinfo.all
  end

  # GET /entry_techinfos/1
  def show
  end

  # GET /entry_techinfos/new
  def new
    @entry_techinfo = EntryTechinfo.new
  end

  # GET /entry_techinfos/1/edit
  def edit
  end

  # POST /entry_techinfos
  def create
    @entry_techinfo = EntryTechinfo.new(entry_techinfo_params)

    if @entry_techinfo.save
      redirect_to @entry_techinfo, notice: 'Entry techinfo was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /entry_techinfos/1
  def update
    if @entry_techinfo.update(entry_techinfo_params)
      redirect_to @entry_techinfo, notice: 'Entry techinfo was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /entry_techinfos/1
  def destroy
    @entry_techinfo.destroy
    redirect_to entry_techinfos_url, notice: 'Entry techinfo was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_entry_techinfo
      @entry_techinfo = EntryTechinfo.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def entry_techinfo_params
      params.require(:entry_techinfo).permit(:entry_id, :song_title, :song_artist, :act_duration_secs, :act_name, :act_description, :costume_Description, :costume_colors, :props, :other_tech_info, :setup_needs, :setup_time_secs, :breakdown_needs, :breakdown_time_secs, :sound_cue, :microphone_needs, :lighting_needs, :mc_intro, :aerial_needs)
    end
end
