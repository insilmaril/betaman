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
      @list = List.find(params[:id])
    else
      flash[:error] = "Access denied: Editing List"
      redirect_to root_path
    end
  end

  def new
    if @current_user.admin?
      @list = List.new

      respond_to do |format|
        format.html 
        format.json { render json: @list }
      end
    else
      flash[:error] = "Access denied: New List"
      redirect_to root_path
    end
  end

  def create
    @list = List.new(params[:list])

    respond_to do |format|
      if @list.save
        flash[:success] = "Created list #{@list.name}"
        format.html { redirect_to @list }
        format.json { render json: @list, status: :created, location: @list }
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
    @list = List.find(params[:id])

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
      list = List.find(params[:id])
      list.destroy
      flash[:success] = "Deleted list #{list.name}"

      respond_to do |format|
        format.html { redirect_to lists_url }
        format.json { head :no_content }
      end
    else
      flash[:error] = "Access denied: Delete list #{list.name}"
      redirect_to root_path
    end
  end

  def users
    @list = List.find(params[:id])
    @users = @list.users
  end

  def sync
    list = List.find(params[:id])
    created, unsubscribed = list.sync
    flash[:success] = "#{created.count} users created"
    flash[:warning] = "#{unsubscribed.count} users unsubscribed"

    redirect_to :back
  end

  def add_select_users
    @list = List.find(params[:id])
    if @current_user.admin? 
      nousers
    end
  end

  def add_multiple_users
    @list = List.find(params[:id])
    #params[:user_ids]       # Cont here and add set of users !!!!!
    if @current_user.admin? 
      if defined?(params[:user_ids])
        #params[:user_ids].each do |id|
        n = params[:user_ids].count
        s = view_context.pluralize(n, 'participant')
        flash[:success] = "Added #{s} to #{@beta.name}"
        params[:user_ids].each do |user|
          @beta.users << User.find(user)
        end
      else
        flash[:warning] = "No Params defined"
      end
    end
  end

  def subscribe_user
    if @current_user.admin? 
      list = List.find(params[:id])
      user = User.find(params[:user_id])
      list.subscribe(user)
      if list.users.include? user
        flash[:success] = "Subscribed #{user.email} to #{list.name}"
      else
        flash[:error] = "Subscribing #{user.email} to #{list.name} failed"
      end
    end
    redirect_to :back
  end

  def unsubscribe_user
    if @current_user.admin? 
      list = List.find(params[:id])
      user = User.find(params[:user_id])
      unsubscribed = list.unsubscribe(user)
      if unsubscribed.include? user
        flash[:success] = "Unsubscribed #{user.email}"
      else
        flash[:error] = "Unsubscribing #{user.email} failed"
      end
    end
    redirect_to :back
  end
end
