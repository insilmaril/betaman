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
        msg = "#{@list.logname} created"
        flash[:success] = msg
        Blog.info msg, @current_user
        format.html { redirect_to @list }
        format.json { render json: @list, status: :created, location: @list }
      else
        msg = "Failed to create #{@list.logname}"
        flash[:warning] = msg
        Blog.warn msg, @current_user
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
        msg = "Updated list #{@list.logname}"
        flash[:success] = msg
        Blog.info msg, @current_user
        format.html { redirect_to @list }
        format.json { head :no_content }
      else
        msg = "Failed to update list #{@list.logname}"
        flash[:warning] = msg
        Blog.warn msg, @current_user
        format.html { render action: "edit" }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @current_user.admin?
      list = List.find(params[:id])
      list.destroy
      msg = "Deleted #{list.logname}"
      flash[:success] = msg
      Blog.info msg, @current_user

      respond_to do |format|
        format.html { redirect_to lists_url }
        format.json { head :no_content }
      end
    else
      flash[:error] = "Access denied: Delete #{list.logname}"
      redirect_to root_path
    end
  end

  def users
    @list = List.find(params[:id])
    @users = @list.users.order :email
  end

  def sync_extern_to_intern
    list = List.find(params[:id])
    added, removed, created = list.sync_extern_to_intern
    Blog.info "#{list.logname} sync_extern_to_intern called:", @current_user
    if added.count > 0 || created.count > 0
      flash[:success] = "#{added.count} users added to internal list, #{created.count} of them created new"
    end
    if removed.count > 0
      flash[:warning] = "#{removed.count} users removed from internal list"
    end
    Blog.info "    Added: #{added.map{|u| u.logname}.join(', ')}", @current_user
    Blog.info "  Created: #{created.map{|u| u.logname}.join(', ')}", @current_user
    Blog.info "  Removed: #{removed.map{|u| u.logname}.join(', ')}", @current_user

    redirect_to :back
  end

  def add_select_users
    @list = List.find(params[:id])
    @nousers = []
    if @current_user.admin? 
      @nousers = User.all
    end
  end

  def add_multiple_users
    @list = List.find(params[:id])
    if @current_user.admin? 
      if defined?(params[:user_ids])
        added = []
        params[:user_ids].each do |user|
          u = User.find(user)
          if u
            @list.users << u
            added << u.logname
          end
        end

        n = added.count
        s = view_context.pluralize(n, 'subscriber')
        msg = "Added #{s} to #{@list.name}: #{added.join(", ")}"
        flash[:success] = msg
        Blog.info msg, @current_user
      else
        flash[:warning] = "No Params defined"
      end
    end
    redirect_to list_path(@list)
  end

  def subscribe_user
    if @current_user.admin? 
      list = List.find(params[:id])
      user = User.find(params[:user_id])
      list.subscribe(user)
      if list.users.include? user

        msg = "Subscribed #{user.logname} to #{list.name}"
        flash[:success] = msg
        Blog.info msg, @current_user
      else
        msg = "Subscribing #{user.email} to #{list.name} failed"
        flash[:error] = msg
        Blog.warn msg, @current_user
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
        msg = "Unsubscribed #{user.logname} from #{list.logname}"
        flash[:success] = msg
        Blog.info msg, @current_user
      else
        msg = "Unsubscribing #{user.email} from #{list.logname} failed"
        flash[:error] = msg
        Blog.warn msg, @current_user
      end
    end
    redirect_to :back
  end
end
