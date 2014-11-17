class EntriesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_cache_buster
  before_action :set_entry, only: [:show, :edit, :update, :destroy]

  before_filter :authenticate_user!

  # GET /entry
  def index
    @entries = Entry.all
  end

  # GET /entry/1
  def show
  end

  # GET /entry/new
  def new
    if ! params.has_key?(:app_id)
      redirect_to apps_url, notice: 'Cannot find that App ID'
      return
    end
    begin
      @app = App.find(params[:app_id])
    rescue Mongoid::Errors::DocumentNotFound
      redirect_to apps_url, error: 'Invalid App ID'
    end

    @entry = Entry.new
  end

  # GET /entry/1/edit
  def edit
  end

  # POST /entry
  def create
    @entry = Entry.new(entry_params)

    if @entry.save
      redirect_to @entry, notice: 'Entry was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /entry/1
  def update
    if ! params.has_key?(:app_id)
      redirect_to apps_url, notice: 'Cannot find that App ID'
      return
    end
    begin
      @app = App.find(params[:app_id])
    rescue Mongoid::Errors::DocumentNotFound
      redirect_to apps_url, error: 'Invalid App ID'
    end
    
    if @entry.update(entry_params)
      redirect_to @entry, notice: 'Entry was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /entry/1
  def destroy
    @entry.destroy
    redirect_to entries_url, notice: 'Entry was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_entry
      @entry = Entry.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def entry_params
      params.require(:entry).permit(:name, :type, :city_from, :country_from, :performer_url, :category, :compete_preference, :video_url, :years_applied, :years_performed, :other_stage_names, :favorite_thing, :years_experience, :style, :why_act_unique, :outside_work, :comments)
    end
end
