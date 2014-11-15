class AppsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_cache_buster
  before_action :set_app, only: [:show, :edit, :update, :destroy]

  protect_from_forgery

  # GET /apps
  def index
    # force the intro rules if necessary...
    #if cookies[:seenintro] == nil
    #  redirect_to "/about/bhof/1"
    #end
    
    @apps = current_user.apps.all

    @apps_incomplete = 0

    if @apps
      @apps.each { |a|
          # TODO: example entry info and techinfo for each application then increment this number.
          @apps_incomplete = @apps_incomplete + 1
      }
    end
  end

  # TODO: ADMIN AND JUDGE INDEXES

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
      redirect_to apps_url, notice: 'Application was successfully updated.'
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
      @app = App.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      @app = nil
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

    if @app == nil
      redirect_to apps_path, :notice => "That application doesn't exist."
    end
    # draw the table

  end

  def payment_paid
    # paypal sends a get request to here, when done,
    #  but we're not done yet, we have to capture funds.
    # 
    # sample callback...
    # http://hubba-dev.retina.net/apps/54615c637265747d8a000000/payment_paid?token=EC-47X445308L645073U&PayerID=F9BZ2FNUEB95N
    begin
      @app = App.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      @error = "Application went away during processing. Please try again."
      redirect_to apps_url, notice: @error
      return
    end        
    
    # have to stash this away for purchase use later. An order is only complete if
    # purchased_at not nil
    @app.purchase_ip = request.remote_ip
    @app.express_token = params[:token]
    @app.express_payer_id = params[:PayerID]
    @app.save             

    if @app.purchase
      @app.purchased_at = Time.now
      if @app.save
        redirect_to dashboard_app_path(@app), :notice => "Thank you for your payment!"
      else
        redirect_to dashboard_app_path(@app), :notice => "Payment failed to process. Please try again."
        logger.notice("Application #{@app.id.to_s} failed to save after payment processed.")
      end
    else
      redirect_to dashboard_app_path(@app), :notice => "Your payment failed."
    end
  end

  def express_checkout
    begin
      @app = App.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      redirect_to "/apps", :notice => "You must specify an application for payment"
    rescue Mongoid::Errors::InvalidFind
      redirect_to "/apps", :notice => "You must specify an application for payment"
    end

    # purchase price is in cents, per paypal's API, USD ($1.00 = 100 cents)
    @app.purchase_price = 100
    @app.save

    response = EXPRESS_GATEWAY.setup_purchase(@app.purchase_price, 
      ip: request.remote_ip,
      return_url: "http://hubba-dev.retina.net/apps/#{@app.id}/payment_paid",
      cancel_return_url: "http://hubba-dev.retina.net/apps/#{@app.id}/payment_cancel",
      currency: "USD",
      allow_guest_checkout: true,
      items: [{name: "BHOF 2015", description: "BHOF 2015 Application", quantity: "1", amount: 100}]
  )
  logger.debug(response.token)
  redirect_to EXPRESS_GATEWAY.redirect_url_for(response.token)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_app
      @app = App.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def app_params
      params.require(:app).permit(:legal_name, :mailing_address, :phone_primary, :phone_alt, :phone_primary_has_sms, :description, :legal_accepted)
    end

end
