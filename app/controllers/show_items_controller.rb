class ShowItemsController < ApplicationController
  before_filter :authenticate_user!
  before_filter do
     redirect_to :new_user_session_path unless current_user && current_user.admin?
  end

  # GET /show_items
  # GET /show_items.json
  def index
    @show_items = ShowItem.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @show_items }
    end
  end

  # GET /show_items/1
  # GET /show_items/1.json
  def show
    @show_item = ShowItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @show_item }
    end
  end

  # GET /show_items/new
  # GET /show_items/new.json
  def new
    @show_item = ShowItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @show_item }
    end
  end

  # GET /show_items/1/edit
  def edit
    @show_item = ShowItem.find(params[:id])
  end

  def update_seq
    # this handler takes care of row reordering from datatables.
    if params[:fromPosition] == params[:toPosition]
      render :text => "Not Modified",:status => 304
      return
    end

    if is_numeric?(params[:fromPosition]) == false or is_numeric?(params[:toPosition]) == false or params[:id] == ""
      render :text => "Invalid Request",:status => 400
      return
    end

    @item = ShowItem.find(params[:id])
    if @item == nil
      headers['Status'] = 404
      render :text => "Show Item Not Found",:status => 404
      return
    end

    from_id = nil
    to_id = nil

    @items = ShowItem.where(show_id: @item.show_id)
    @items.each { |i|
      if i.seq.to_i == params[:toPosition].to_i
          to_id = i
      end
      if i.seq.to_i == params[:fromPosition].to_i
          from_id = i
      end
    }

    if from_id != nil and to_id != nil
      to_id.seq = params[:fromPosition].to_i
      to_id.save!
      from_id.seq = params[:toPosition].to_i
      from_id.save!
    else
      render :text => "Not Found - f:#{from_id} t:#{to_id} sid:#{@item.show_id} pf:#{params[:toPosition]} pt: #{params[:fromPosition]}", :status => 404
      return
    end

    render :text => "Ok",:status => 200

  end

  # POST /show_items/id/move.json
  def move
    # move a show item up or down in the setlist
    @row_id = params[:row_id]
    @direction = params[:direction]
    @show_items = ShowItem.where(show_id: params[:show_id]).asc(:seq)

    if (@row_id.to_i == @show_items[0].seq and @direction == "up") or
        params[:direction].is_empty? or
        params[:row_id].is_empty?
      # criteria not met
      render json: {}, :status => 400
      return
    end

    if @showitems.length == 0
      render json: {}, :status => 404
      return
    end

    last_item = nil
    the_item = nil

    if @direction == "up"
      @show_items.each { |si| 
        logger.debug si.seq
        if si.seq.to_i == @row_id.to_i
          # swap the items
          the_item = si
          logger.debug "found item"
          stash = the_item.seq
          the_item.seq = last_item.seq
          last_item.seq = stash
          the_item.save!
          last_item.save!
        end
        last_item = si 
      }
    else
      @show_items.reverse.each { |si| 
        logger.debug si.seq
        if si.seq.to_i == @row_id.to_i
          # swap
          the_item = si
          logger.debug "found item"
          stash = the_item.seq
          the_item.seq = last_item.seq
          last_item.seq = stash
          the_item.save!
          last_item.save!
        end
        last_item = si 
      }
    end

    if the_item == nil
      render json: {}, :status => 404
    else
      render json: @the_item, :status => 200
    end
  end

  # POST /show_items
  # POST /show_items.json
  def create
    @show_item = ShowItem.new(params[:show_item])

    # figure out the max ID.
    seq = 0
    @show_items = ShowItem.where(show_id: params[:show_id])
    if @show_items
      @show_items.each { |s|
        if s.seq > seq
          seq = s.seq
        end
      }
    end
    seq = seq + 1

    @show_item.seq = seq

    if @show_item.act_id != nil
      if @show_item.act_id != "0"
        # if an act_id is supplied, we'll pull the duration from the user's input.
        act = Act.find(@show_item.act_id)
        @show_item.duration = act.length
      end
    end

    respond_to do |format|
      if @show_item.save
        format.html { redirect_to @show_item, notice: 'Show item was successfully created.' }
        format.json { render json: @show_item, status: :created, location: @show_item }
      else
        format.html { render action: "new" }
        format.json { render json: @show_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /show_items/1
  # PUT /show_items/1.json
  def update
    @show_item = ShowItem.find(params[:id])

    respond_to do |format|
      if @show_item.update_attributes(params[:show_item])
        format.html { redirect_to @show_item, notice: 'Show item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @show_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /show_items/1
  # DELETE /show_items/1.json
  def destroy
    @show_item = ShowItem.find(params[:id])
    @show_item.destroy

    respond_to do |format|
      format.html { redirect_to show_items_url }
      format.json { head :no_content }
    end
  end

  private

  def is_numeric?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end
end
