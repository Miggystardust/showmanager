# true/false monkeypatch - I had to add this again for this class, no idea why. 
require "#{Rails.root}/lib/yesno.rb"

class TroupesController < ApplicationController

 protect_from_forgery

 before_filter :authenticate_user!

  # GET /troupes
  # GET /troupes.json
  def index
    case params[:type]
    when "all"
      @trs = Troupe.find(:all)
    when "public"
      @trs = Troupe.where(private: false).not_in(user_id: current_user.id)
    else
      # troupes you own and stuff you are a member of
      @trs = Troupe.where(user_id: current_user.id)
    end
   
    @troupedt = []
    @trs.each { |t| 
      if t.user_id 
        owner = User.find(t.user_id)
        @troupedt <<  [t.name, t.description, t.private.yesno, owner.name, t.id.to_s + '|U']
      end
    }

    if params[:type] != 'public'
        current_user.troupe_memberships.each { |tm| 
          if tm.troupe 
            owner = User.find(tm.troupe.user_id)
            @troupedt <<  [tm.troupe.name, tm.troupe.description, tm.troupe.private.yesno, owner.name, tm.troupe.id.to_s + '|M']
          end
        }
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: { 'aaData' => @troupedt } }
    end
  end

  # GET /troupes/1
  # GET /troupes/1.json
  def show
    @troupe = Troupe.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @troupe }
    end
  end

  # GET /troupes/new
  # GET /troupes/new.json
  def new
    @troupe = Troupe.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @troupe }
    end
  end

  # GET /troupes/1/edit
  def edit
    @troupe = Troupe.find(params[:id])
  end

  # POST /troupes
  # POST /troupes.json
  def create
    @troupe = Troupe.new(params[:troupe])

    @troupe.user_id = current_user.id

    respond_to do |format|
      if @troupe.save
        current_user.troupes << @troupe
        current_user.save!
        
        format.html { redirect_to "/troupes", notice: 'Troupe was successfully created.' }
        format.json { render json: @troupe, status: :created, location: @troupe }
      else
        format.html { render action: "new" }
        format.json { render json: @troupe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /troupes/1
  # PUT /troupes/1.json
  def update
    @troupe = Troupe.find(params[:id])

    respond_to do |format|
      if @troupe.update_attributes(params[:troupe])
        format.html { redirect_to "/troupes/", notice: 'Troupe was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @troupe.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /troupes/1
  # DELETE /troupes/1.json
  def destroy
    @troupe = Troupe.find(params[:id])
    if @troupe.user_id != current_user.id 
      respond_to do |format|
        format.html { redirect_to troupes_url, notice: "You do not own that troupe." } 
        format.json { head :no_content }
      end
      return
    end

    @troupe.destroy

    respond_to do |format|
      format.html { redirect_to troupes_url, notice: "Troupe deleted." }
      format.json { head :no_content }
    end

  end

  def leave
    begin 
      @troupe = Troupe.find(params[:id])
    rescue
      respond_to do |format|
        format.html { redirect_to "/troupes/", notice: 'Troupe does not exist.' }
        format.json { head :no_content }
      end
    end

    current_user.troupe_memberships.each { |tm|
      if tm.troupe_id == @troupe.id
        tm.destroy
        redirect_to "/troupes/", notice: "You have left troupe \"#{tm.troupe.name}\""
        return
      end
    }

    redirect_to "/troupes/", notice: 'You are not a member of that troupe.'
  end

  def join
    # does the troupe exist?
    begin 
      @troupe = Troupe.find(params[:id])
    rescue
      respond_to do |format|
        format.html { redirect_to "/troupes/", notice: 'Troupe does not exist.' }
        format.json { head :no_content }
      end
      return
    end

    # are we already a member?
    current_user.troupe_memberships.each { |tm|
      if tm.troupe_id and tm.troupe_id == @troupe.id
         respond_to do |format|
           format.html { redirect_to "/troupes/", notice: "You are already a member of \"#{@troupe.name}\"." }
           format.json { head :no_content }
         end
         return
      end
    }    

    # TODO: private check or auth-code check goes here
    # TODO: invitations, yous hou

    if @troupe.private == true and params[:auth].empty?  
         respond_to do |format|
           format.html { redirect_to "/troupes/", notice: 'You cannot join that troupe. It is private.' }
           format.json { head :no_content }
         end
         return
    end

    # add the user to the troupe 
    tm = TroupeMembership.new
    tm.user_id = current_user.id 
    tm.troupe_id = @troupe.id
    tm.save

    respond_to do |format|
      format.html { redirect_to "/troupes/", notice: "Joined troupe: #{@troupe.name}" }
      format.json { head :no_content }
    end
  end

end
