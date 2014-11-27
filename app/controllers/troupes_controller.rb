# true/false monkeypatch - I had to add this again for this class, no idea why. 
require "#{Rails.root}/lib/yesno.rb"

class TroupesController < ApplicationController

  protect_from_forgery

  before_filter :authenticate_user!

  # GET /troupes
  # GET /troupes.json
  def index

    case params[:type]
    when "all"
      @trs = Troupe.find(:all)
    when "public"
      @trs = Troupe.where(private: false)
    else
      # troupes you own and stuff you are a member off
      @trs = Troupe.where(user_id: current_user.id)

    end
   
    @troupedt = []
    @trs.each { |t| 
      owner = User.find(t.user_id)
      @troupedt <<  [t.name, t.description, t.private.yesno, owner.name, t.id.to_s]
    }

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: { 'aaData' => @troupedt } }
    end
  end

  # GET /troupes/1
  # GET /troupes/1.json
  def show
    @troupe = Troupe.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @troupe }
    end
  end

  # GET /troupes/new
  # GET /troupes/new.json
  def new
    @troupe = Troupe.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @troupe }
    end
  end

  # GET /troupes/1/edit
  def edit
    @troupe = Troupe.find(params[:id])
  end

  # POST /troupes
  # POST /troupes.json
  def create
    @troupe = Troupe.new(params[:troupe])

    respond_to do |format|
      if @troupe.save
        current_user.troupes << @troupe
        current_user.save!
        
        format.html { redirect_to "/troupes", notice: 'Troupe was successfully created.' }
        format.json { render json: @troupe, status: :created, location: @troupe }
      else
        format.html { render action: "new" }
        format.json { render json: @troupe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /troupes/1
  # PUT /troupes/1.json
  def update
    @troupe = Troupe.find(params[:id])

    respond_to do |format|
      if @troupe.update_attributes(params[:troupe])
        format.html { redirect_to "/troupes/", notice: 'Troupe was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @troupe.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /troupes/1
  # DELETE /troupes/1.json
  def destroy
    @troupe = Troupe.find(params[:id])
    @troupe.destroy

    respond_to do |format|
      format.html { redirect_to troupes_url }
      format.json { head :no_content }
    end
  end

  def join
    begin 
      @troupe = Troupe.find(params[:id])
    rescue
      respond_to do |format|
        format.html { redirect_to "/troupes/", notice: 'Troupe does not exist.' }
        format.json { head :no_content }
      end
    end

    tm = Troupe_membership.new
    tm.user_id = current_user.id 
    tm.troupe_id = 
    tm.save

    # TODO: private check or auth-code check goes here
      respond_to do |format|
        format.html { redirect_to "/troupes/", notice: 'Troupe does not exist.' }
        format.json { head :no_content }
      end
  end

end
