class BhofController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]

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
    # first page does not require authentication
    render 'page0'
  end

end