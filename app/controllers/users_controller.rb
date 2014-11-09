# true/false monkeypatch - I had to add this again for this class, no idea why. 
require "#{Rails.root}/lib/yesno.rb"

include ActionView::Helpers::NumberHelper

class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    if current_user.try(:admin?)
      @users = User.all
      respond_to do |format|
        format.html # index.html.erb
        format.json {
          # drive datatables
          @usersarray = []
          @users.each { |user|
            @usersarray << [user.username, user.email, number_to_phone(user.phone_number), user.last_sign_in_at.strftime(SHORT_TIME_FMT), user.provider, user.admin.yesno, user.id.to_s]
          }
          render json: { 'aaData' => @usersarray }
        }
      end

    else
      flash[:error] = "You must be an administrator to use that function."
      redirect_to "/"
    end
  end

  def show
    if current_user.try(:admin?)
      begin
        @user = User.find(params[:id])
      rescue Mongoid::Errors::DocumentNotFound
        redirect_to root_url, error: "The requested user does not exist."
        return
      end
      render :show
    else
      flash[:error] = "You must be an administrator to use that function."
      redirect_to "/"
    end
  end

  def update
    if current_user.try(:admin?)
      begin
        @user = User.find(params[:id])
        @user.update_attributes(params[:user])
      rescue Mongoid::Errors::DocumentNotFound
        redirect_to root_url, error: "The requested user does not exist."
        return
      end
      
      # This is the only time we permit the admin bit to be flipped.
      # you must be an admin first and we have to set this locally due
      # to mass assignment protection.  

      if params[:user][:admin] == "1" then
         @user.admin = true 
      else 
         @user.admin = false 
      end

      @user.save!
      flash[:notice] = "User Updated."
      redirect_to "/users"
    else
      flash[:error] = "You must be an administrator to use that function."
      redirect_to "/"
    end
  end

  def destroy
    if current_user.try(:admin?)
      begin
        @user = User.find(params[:id])
      rescue Mongoid::Errors::DocumentNotFound
        redirect_to users_url, error: "The requested user doesn't exist."
        return
      end

      @user.destroy

      if @user.destroy
        redirect_to users_url, notice: "User #{@user.username} (#{@user.name}) deleted."
      end
    else
      redirect_to root_url, error: "You must be an Administrator to do that."
    end

  end

  private


  def user_params
    params.require(:user).permit( :name, :username, :email, :password, :password_confirmation, :remember_me, :uid, :provider )
  end

end
