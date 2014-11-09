class BhofController < ApplicationController
  before_filter :authenticate_user!

  def index
      @page = params[:page].to_i
      case params[:page]
        when "3"
          cookies[:seenintro] = {
              :value => true,
              :expires => 6.months.from_now
          }
          render "page3.html.erb"
          return
        when "2"
          render "page2.html.erb"
          return
        else
          @page=1
          render "page1.html.erb"
          return
      end
  end

  # note that 'help' automatically works here and can be used to get rules or judging criteria (nice!3)


end