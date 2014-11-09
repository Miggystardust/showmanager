class BhofController < ApplicationController

  def index
      case params[:page]
        when "3"
          render "page3.html.erb"
          return
        when "2"
          render "page2.html.erb"
          return
        else
          render "page1.html.erb"
          return
      end

  end

end