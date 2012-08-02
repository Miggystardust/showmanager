class UsersController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    if current_user.try(:admin?) 
      @users = User.all
      render :index
    else 
      flash[:error] = "You must be an administrator to use that function."
      redirect_to "/"
    end
  end

  def show
    if current_user.try(:admin?) 
      @user = User.find(params[:id])
      render :show
    else 
      flash[:error] = "You must be an administrator to use that function."
      redirect_to "/"
    end
  end

end
