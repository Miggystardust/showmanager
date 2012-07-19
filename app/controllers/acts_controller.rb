class ActsController < ApplicationController
  protect_from_forgery

  before_filter :authenticate_user!
  before_filter :set_cache_buster
  before_filter :build_user_selects, :except => [ :destroy ]
      
  def build_user_selects
    # we build this every pass because we use them in most operations
    @user_imgs = [['None',0]]
    @user_musics = [['None',0],["We'll make our own",1]]
    
    if current_user.try(:admin?) 
      # admins get to see everything.
      ui = Passet.where(kind: /^image\//)
      um = Passet.where(kind: /^audio\//)
    else 
      ui = current_user.passets.where(kind: /^image\//)
      um = current_user.passets.where(kind: /^audio\//)
    end

    ui.each do |u|
      logger.debug(u.id)
      @user_imgs << [u.filename,u.id]
    end
    
    um.each do |u|
      logger.debug(u.id)
      @user_musics << [u.filename,u.id]
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
    if current_user.try(:admin?) == false
      flash[:error] = "You must be an administrator to do that."
      redirect_to :index
    end
    
    @acts = Act.all
    @showowner = true
      
    respond_to do |format|
      format.html { render :action => "index" }
      format.json { 
        # this format is used to drive the show editing page. It is a digusting O(n) query. I do not care.
        # talk to me when we have 100k users. 
        @actarray = []
        @acts.each { |a| 
          @actarray << [a.user.name, a.stage_name, a.short_description, a.length, "<button class=\"btn btn-success actadder\" id=\"#{a._id}\"><i class=\"icon-plus icon-white\"></i> Add</button>"]
        }
        render json: { 'aaData' => @actarray }
      }
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
    
    if @act.id != current_user.id and current_user.try(:admin?) == false
      flash[:error] = "You don't own that Act."
      redirect_to "/acts/"
    end
    
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