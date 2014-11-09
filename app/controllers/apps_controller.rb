class AppsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_cache_buster
  before_action :set_app, only: [:show, :edit, :update, :destroy]

  protect_from_forgery

  # GET /apps
  def index
    # force the intro rules if necessary...
    if cookies[:seenintro] == nil
      redirect_to "/about/bhof/1"
    end
    
    @apps = App.all
  end

  # GET /apps/1
  def show
  end

  # get /apps/updateme
  def updateme
    @app = Apps.where(user_id: current_user.__id__)

  end

  # GET /apps/new
  def new
    @app = App.new
  end

  # GET /apps/1/edit
  def edit
  end

  # POST /apps
  def create
    @app = App.new(app_params)
    @app.created_at=Time.now

    if @app.save
      current_user.apps << @app
      current_user.save!

      redirect_to apps_path, notice: 'Application was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /apps/1
  def update

    if @app.update(app_params)
      redirect_to @app, notice: 'Application was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /apps/1
  def destroy
    @app.destroy
    redirect_to apps_url, notice: 'Application was successfully destroyed.'
  end

  def dashboard

    begin
      @application = App.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      @application = nil
    end

    begin
      @entry = Entry.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      @entry = nil
    end

    begin
      @entry_tech = EntryTechinfo.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      @entry_tech = nil
    end

    if @application == nil
      redirect_to apps_path, :notice => "That application doesn't exist."
    end
    # draw the table

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_app
      @app = App.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def app_params
      params.require(:app).permit(:legal_name, :mailing_address, :phone_primary, :phone_alt, :phone_primary_has_sms, :description)
    end

end
