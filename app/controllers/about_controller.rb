class AboutController < ApplicationController
  protect_from_forgery

  def tos
  end

  def privacy
  end

  def support
  end
  
  
  # GET /about/bhof/nnnnn
  def bhof
    case params[:id]
    when "3"
      render "/about/bhof/page3.html.erb"
      return
    when "2"
      render "/about/bhof/page2.html.erb"
      return
    else
      render "/about/bhof/page1.html.erb"
      return
    end
  end
  
end
