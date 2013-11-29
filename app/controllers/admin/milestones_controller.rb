class Admin::MilestonesController < ApplicationController
  before_filter :admin_required

  def index
    @milestones = Milestone.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @milestones }
    end
  end

  def edit
    if @current_user.admin?
      @milestone = Milestone.find(params[:id])
    else
      flash[:error] = "Access denied: Editing Milestone"
      redirect_to root_path
    end
  end

  def new
    if @current_user.admin?
      @milestone = Milestone.new

      respond_to do |format|
        format.html 
        format.json { render json: @milestone }
      end
    else
      flash[:error] = "Access denied: New Milestone"
      redirect_to root_path
    end
  end

  def create
    @milestone = Milestone.new(params[:milestone])

    respond_to do |format|
      if @milestone.save
        flash[:success] = "Created milestone #{@milestone.name}"
        format.html { redirect_to admin_milestones_path}
        format.json { render json: @milestone, status: :created, location: @milestone }
      else
        flash[:warning] = "Failed to create milestone #{@milestone.name}"
        format.html { render action: "new" }
        format.json { render json: @milestone.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @milestone = Milestone.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @milestone }
    end
  end

  def update
    @milestone = Milestone.find(params[:id])

    respond_to do |format|
      if @milestone.update_attributes(params[:milestone])
        flash[:success] = "Updated milestone #{@milestone.name}"
        format.html { redirect_to admin_milestones_path }
        format.json { head :no_content }
      else
        flash[:warning] = "Failed to update milestone #{@milestone.name}"
        format.html { render action: "edit" }
        format.json { render json: @milestone.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @current_user.admin?
      milestone = Milestone.find(params[:id])
      milestone.destroy
      flash[:success] = "Deleted milestone #{milestone.name}"

      respond_to do |format|
        format.html { redirect_to admin_milestones_path }
        format.json { head :no_content }
      end
    else
      flash[:error] = "Access denied: Delete milestone #{milestone.name}"
      redirect_to root_path
    end
  end

end
