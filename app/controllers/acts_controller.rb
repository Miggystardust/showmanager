class ActsController < ApplicationController
  protect_from_forgery

  before_filter :authenticate_user!
  before_filter :set_cache_buster
  before_filter :build_user_selects
    
  def build_user_selects
    # we build this every pass because we use them in most operations
    @user_imgs = [['None',0]]
    @user_musics = [['None',0],["We'll make our own",1]]
    
    ui = current_user.passets.where(kind: /^image\//)
    ui.each do |u|
      logger.debug(u.id)
      @user_imgs << [u.filename,u.id]
    end
    
    um = current_user.passets.where(kind: /^audio\//)
    um.each do |u|
      logger.debug(u.id)
      @user_imgs << [u.filename,u.id]
    end
    
  end

  # GET /acts
  # GET /acts.json
  def index
    @acts = current_user.acts.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @acts }
    end
  end

  def adminindex
    @acts = Act.acts.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @acts }
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
  end

  # POST /acts
  # POST /acts.json
  def create
    @act = Act.new(params[:act])
    
    current_user.passets.where()

    respond_to do |format|
      if @act.save
        current_user.acts << @act
        current_user.save!
        
        format.html { redirect_to "/acts/", notice: 'Act was successfully created.' }
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

    respond_to do |format|
      if @act.update_attributes(params[:act])
        format.html { redirect_to "/acts/", notice: 'Act was successfully updated.' }
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
      format.html { redirect_to acts_url }
      format.json { head :no_content }
    end
  end
end
