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
            @usersarray << [user.username, user.email, number_to_phone(user.phone_number), user.last_sign_in_at.strftime(SHORT_TIME_FMT), user.provider, user.admin.yesno, user.id]
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
      @user = User.find(params[:id])
      render :show
    else
      flash[:error] = "You must be an administrator to use that function."
      redirect_to "/"
    end
  end

end
