class TroupesController < ApplicationController
  # GET /troupes
  # GET /troupes.json
  def index

    case params[:type]
    when "all"
      @troupes = Troupe.find(:all)
    when "public"
      @troupes = Troupe.where(private: false)
    else
      @troupes = current_user.troupes.all
    end

    @troupedt = []
    @troupes.each { |t| 
      @troupedt << [t.name, t.description, t.private.yesno, t.user.name, t.id]
    }

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
    @troupe.destroy

    respond_to do |format|
      format.html { redirect_to troupes_url }
      format.json { head :no_content }
    end
  end
end
