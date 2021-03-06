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
        Diary.list_created actor: @current_user, text: "List: #{@list.id} - #{@list.name}"
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
        Diary.list_updated actor: @current_user, text: "List: #{@list.id} - #{@list.name}"
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
      Diary.list_deleted actor: @current_user, text: "List: #{list.id} - #{list.name}"
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

  def sync_to_intern
    list = List.find(params[:id])
    r = list.sync_to_intern
    if r[:added_to_list].count > 0 || r[:created].count > 0
      flash[:success] = "#{r[:added_to_list].count} users added to internal list, #{r[:created].count} of them created new"
    end
    if r[:dropped_from_list].count > 0
      flash[:warning] = "#{r[:dropped_from_list].count} users dropped from internal list"
    end

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
      listchanges = list.sync_to_intern
      if listchanges[:added_to_list].include? user

        msg = "Subscribed #{user.logname} to #{list.name}"
        flash[:success] = msg
        Blog.info msg, @current_user
        Diary.subscribed_user_to_list user: user, list: list, actor: @current_user
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
      list.unsubscribe(user)
      listchanges = list.sync_to_intern
      if listchanges[:dropped_from_list].include? user
        msg = "Unsubscribed #{user.logname} from #{list.logname}"
        flash[:success] = msg
        Blog.info msg, @current_user
      else
        msg = "Unsubscribing #{user.email} from #{list.logname} failed"
        flash[:error] = msg
        Blog.warn msg, @current_user
        Diary.unsubscribed_user_from_list user: user, list: list, actor: @current_user
      end
    end
    redirect_to :back
  end
end
