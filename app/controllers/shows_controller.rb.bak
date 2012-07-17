class ShowsController < ApplicationController
  protect_from_forgery

  before_filter :authenticate_user!

  def index
    @shows = Show.all.desc(:show_time)
  end

  def setlist
    @show = Show.find(params[:id])
    # this overloading is a bit gross, should move into it's own call
    if params[:additem] 
      if params[:additem][:uuid] != nil
        @s = ShowItems.new(kind: "asset",
                          uuid: params[:additem][:uuid])
        @s.save!
        flash[:notice] = "Item added."
      end
    end

    # if we are adding here, add to the model...
    @show_items = ShowItems.where(:show_id => params[:id])
  end

  def create
    @s = Show.new(title: params[:show][:title],
                  show_time: params[:show][:show_time],
                  door_time: params[:show][:door_time],
                  venue: params[:show][:venue])
    begin 
      @s.save!
      flash[:notice] = "Show created."
    rescue Mongoid::Errors::InvalidTime
      flash[:error] = "Invalid Date."
    rescue Mongoid::Errors::Validations
      flash[:error] = "Save Failed. All fields are required."
    end

    redirect_to :action => :index
  end

  def edit
    @show = Show.find(params[:id])
  end

  def update
    @show = Show.find(params[:id])

    @show.update_attributes(title: params[:show][:title],
                            show_time: params[:show][:show_time],
                            door_time: params[:show][:door_time],
                            venue: params[:show][:venue])
    begin 
      @show.save!
      flash[:notice] = "Changes Saved."
    rescue Mongoid::Errors::InvalidTime
      flash[:error] = "Invalid Date."
    rescue Mongoid::Errors::Validations
      flash[:error] = "Save Failed. All fields are required."
    end

    redirect_to :action => :index

  end

  def destroy
    s = Show.find(params[:id])

    if s != nil
      s.destroy
    end
    flash[:notice] = "Show removed."
    redirect_to :action => :index
  end 

end
