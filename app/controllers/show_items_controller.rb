class ShowItemsController < ApplicationController
  before_filter :authenticate_user!
  before_filter do 
     redirect_to :new_user_session_path unless current_user && current_user.admin?
  end

  # GET /show_items
  # GET /show_items.json
  def index
    @show_items = ShowItem.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @show_items }
    end
  end

  # GET /show_items/1
  # GET /show_items/1.json
  def show
    @show_item = ShowItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @show_item }
    end
  end

  # GET /show_items/new
  # GET /show_items/new.json
  def new
    @show_item = ShowItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @show_item }
    end
  end

  # GET /show_items/1/edit
  def edit
    @show_item = ShowItem.find(params[:id])
  end

  # POST /show_items
  # POST /show_items.json
  def create
    @show_item = ShowItem.new(params[:show_item])

    respond_to do |format|
      if @show_item.save
        format.html { redirect_to @show_item, notice: 'Show item was successfully created.' }
        format.json { render json: @show_item, status: :created, location: @show_item }
      else
        format.html { render action: "new" }
        format.json { render json: @show_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /show_items/1
  # PUT /show_items/1.json
  def update
    @show_item = ShowItem.find(params[:id])

    respond_to do |format|
      if @show_item.update_attributes(params[:show_item])
        format.html { redirect_to @show_item, notice: 'Show item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @show_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /show_items/1
  # DELETE /show_items/1.json
  def destroy
    @show_item = ShowItem.find(params[:id])
    @show_item.destroy

    respond_to do |format|
      format.html { redirect_to show_items_url }
      format.json { head :no_content }
    end
  end
end
