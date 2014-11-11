class BhofController < ApplicationController
  before_filter :authenticate_user!

  ALLOWED_PAGES=['rules','judging_criteria','instructions','page1','page2','page3']
  def show
    # whitelist acceptable pages here. This controller serves primarily static pages.
    if ALLOWED_PAGES.include?(params[:id])
      render params[:id]
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def index
   redirect_to action: 'show', id: "page1"
  end

end