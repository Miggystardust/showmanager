class InvitationController < ApplicationController

protect_from_forgery

before_filter :authenticate_user!

def index
  # get all of the pending invites for a particular user to allow for retractions, etc.
  @invites = Invitation.where(sender: current_user)
end

def create
  @invitation = Invitation.new(params[:invitation])
  @invitation.sender = current_user

  if @invitation.save
      Mailer.deliver_invitation(@invitation, signup_url(@invitation.token))
      flash[:notice] = "Thank you, invitation sent."
      redirect_to troupes_url
  else
    render :action => 'new'
  end
end

end
