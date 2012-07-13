class ActsController < ApplicationController
  before_filter :authenticate_user!
  
  protect_from_forgery
  
  def index
    @acts = current_user.acts.all
  end

  def new
    # show it
  end
  
  def create
    @a = Act.new(params)
    current_user.acts << @a
    redirect_to :index
  end

  def show
    @act = Acts.find(params[:id])
  end

end
