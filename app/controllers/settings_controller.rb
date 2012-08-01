class SettingsController < ApplicationController
  def edit
    @user = current_user
  end

  def update
    @user = User.find(current_user.id)

    email_changed = @user.email != params[:user][:email]
    
    if params[:user][:password] == nil 
      password_changed = false
    else 
      password_changed = !params[:user][:password].empty?
    end

    successfully_updated = if email_changed or password_changed
                             @user.update_with_password(params[:user])
                           else
                             @user.update_without_password(params[:user])
                           end
    
    if successfully_updated
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true
      flash[:notice] = "Your profile has been updated."
      redirect_to "/settings/edit"
    else
      render "edit"
    end
  end
end
