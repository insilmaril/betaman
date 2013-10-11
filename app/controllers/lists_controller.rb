class ListsController < ApplicationController
  def index
    @lists = List.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lists }
    end
  end

  def edit
    if @current_user.admin?
      init_instance_variables
    else
      flash[:error] = "Access denied: Editing List"
      redirect_to root_path
    end
  end

  def new
    if @current_user.admin?
    @list = List.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @list }
    end
    else
      flash[:error] = "Access denied: New List"
      redirect_to root_path
    end
  end

  def create
    @list = Beta.new(params[:list])

    respond_to do |format|
      if @list.save
        flash[:success] = "Created list #{@list.name}"
        format.html { redirect_to @beta }
        format.json { render json: @beta, status: :created, location: @list }
      else
        flash[:warning] = "Failed to create list #{@list.name}"
        format.html { render action: "new" }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @list = List.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @list }
    end
  end

  def update
    init_instance_variables

    respond_to do |format|
      if @list.update_attributes(params[:list])
        flash[:success] = "Updated list #{@list.name}"
        format.html { redirect_to @list }
        format.json { head :no_content }
      else
        flash[:warning] = "Failed to update list #{@list.name}"
        format.html { render action: "edit" }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @current_user.admin?
      init_instance_variables
      @list.destroy

      respond_to do |format|
        format.html { redirect_to lists_url }
        format.json { head :no_content }
      end
    else
      flash[:error] = "Access denied: Delete list test"
      redirect_to root_path
    end
  end

  def users
    @list = List.find(params[:id])
    @users = @list.users
  end

  def refresh
    list = List.find(params[:id])
    created, unsubscribed = list.refresh
    flash[:success] = "#{created.count} users created"
    flash[:warning] = "#{unsubscribed.count} users unsubscribed"

    redirect_to :back
  end
end
