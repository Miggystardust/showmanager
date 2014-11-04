class AppsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_cache_buster
  before_action :set_app, only: [:show, :edit, :update, :destroy]

  protect_from_forgery
  
  def enter
    # upon entrance, cookie the user so we don't ask again about the rules.
    cookies[:seen_intro] = {
      :value => "true",
      :expires => 6.months.from_now()
    }

    # TODO: have a way of reversing this via a checkbox or otherwise.
    
    redirect_to apps_url
  end 

  # GET /apps
  def index
    # force the intro rules if necessary...
    if cookies[:seen_intro] == nil
      redirect_to "/about/bhof/1"
    end
    
    @apps = App.all
  end

  # GET /apps/1
  def show
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

    if @app.save
      redirect_to @app, notice: 'App was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /apps/1
  def update
    if @app.update(app_params)
      redirect_to @app, notice: 'App was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /apps/1
  def destroy
    @app.destroy
    redirect_to apps_url, notice: 'App was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_app
      @app = App.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def app_params
      params.require(:app).permit(:legal_name, :mailing_address, :phone_primary, :phone_alt, :phone_primary_has_sms)
    end
end
