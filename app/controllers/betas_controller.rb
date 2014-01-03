class BetasController < ApplicationController
  def index
    @betas = Beta.all
    @active_betas = Beta.active
    @planned_betas = Beta.planned
    @finished_betas = Beta.finished

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @betas }
    end
  end

  def edit
    if @current_user.admin?
      @beta = Beta.find(params[:id])

    else
      flash[:error] = "Access denied: Editing Beta test"
      redirect_to root_path
    end
  end

  def new
    if @current_user.admin?
      @beta = Beta.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @beta }
      end
    else
      flash[:error] = "Access denied: New Beta test"
      redirect_to root_path
    end
  end

  def create
    @beta = Beta.new(params[:beta])

    respond_to do |format|
      if @beta.save
        flash[:success] = "Created beta #{@beta.name}"
        format.html { redirect_to @beta }
        format.json { render json: @beta, status: :created, location: @beta }
      else
        flash[:warning] = "Failed to create beta #{@beta.name}"
        format.html { render action: "new" }
        format.json { render json: @beta.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @beta = Beta.find(params[:id])
    @users = @beta.users

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @beta }
    end
  end

  def update
    @beta = Beta.find(params[:id])

    respond_to do |format|
      if @beta.update_attributes(params[:beta])
        flash[:success] = "Updated beta #{@beta.name}"
        format.html { redirect_to @beta }
        format.json { head :no_content }
      else
        flash[:warning] = "Failed to update beta #{@beta.name}"
        format.html { render action: "edit" }
        format.json { render json: @beta.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @current_user.admin?
      @beta = Beta.find(params[:id])
      @beta.destroy

      respond_to do |format|
        format.html { redirect_to betas_url }
        format.json { head :no_content }
      end
    else
      flash[:error] = "Access denied: Delete Beta test"
      redirect_to root_path
    end
  end

  def users
    @beta = Beta.find(params[:id])
    @users = @beta.users
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: UsersDatatable.new(view_context, @beta) }
    end
  end

  def init_nousers
    @nousers = User.all - @beta.users
  end

  def add_user
    @beta = Beta.find(params[:id])
    user = User.find(params[:user_id])

    if @current_user.admin?
      if !@beta.users.include? user
        @beta.users << user
        flash[:success] = "Added #{user.full_name} to #{@beta.name}"
      else
        flash[:warning] = "#{user.full_name} is already member of #{@beta.name}"
      end

      redirect_to :back
    end
  end

  def add_select_users
    @beta = Beta.find(params[:id])
    @nousers = init_nousers
  end

  def add_multiple_users
    @beta = Beta.find(params[:id])
    if @current_user.admin? 
      if defined?(params[:user_ids])
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
    redirect_to beta_path(@beta)
  end

  def add_list_subscribers
    @beta = Beta.find(params[:id])
    list = List.find(params[:list_id])
    if @current_user.admin? && list && @beta
      added, existing = @beta.add_users(list.users)
      all_count   = view_context.pluralize(list.users.count, 'subscriber')
      added_count = view_context.pluralize(added.count, 'participant')
      exist_count = view_context.pluralize(existing.count, 'participant')
      flash[:success] = "Added #{added_count} to #{@beta.name}, found already #{exist_count}."
      UserMailer.admin_mail(
        "Added #{added_count} from #{list.name} to beta #{@beta.name}",
        "Beta: #{@beta.name}\n" +
        "List: #{list.name}\n\n" +
        "request to add #{all_count} resulted in \n" +
        "  #{added_count} added (see below) and\n" +
        "  #{exist_count} already existing\n\n" +
        added.join("\n")
      ).deliver
    end
    redirect_to beta_path(@beta)
  end

  def remove_user
    @beta = Beta.find(params[:id])

    user = User.find(params[:user_id])

    if @current_user.admin?
      if @beta.users.include? user
        @beta.users.delete(user)
        flash[:success] = "Removed #{user.full_name} from #{@beta.name}"
      else
        flash[:warning] = "User #{user.full_name} is not a member of beta #{@beta.name}!"
      end
      redirect_to :back
    end
  end

  def add_list
    if @current_user.admin?
      beta = Beta.find(params[:id])
      newlist = List.find(params[:list_id])
      if beta.list
        flash[:error] = "#{beta.name} already has a list named #{beta.list.name}"
      else
        beta.list = newlist
        flash[:success] = "Added list #{newlist.name} to #{beta.name}"
      end
    end
    redirect_to :back
  end

  def remove_list
    if @current_user.admin?
      beta = Beta.find(params[:id])
      if beta.list
        flash[:success] = "Removed list #{beta.list.name} from  #{beta.name}"
        beta.list = nil
      else
        flash[:error] = "#{beta.name} has no mailing list"
      end
    end
    redirect_to :back
  end

  def join
    @beta = Beta.find(params[:id])
    if !@beta.users.include? @current_user
      flash[:success] = "Added #{@current_user.full_name} to #{@beta.name}"
      @beta.users << @current_user

      if !@beta.list.nil?
        list =  @beta.list.users
        if list 
          if !list.include?(@current_user)
            list.subscribe @current_user
            flash[:success] = "Subscribed #{@current_user.full_name} to #{list.name} list"
          else
            flash[:warning] = "#{@current_user.full_name} is already subscribed to #{list.name} list"
          end
        end
      end

      redirect_to :back
    end
  end

  def leave
    @beta = Beta.find(params[:id])
    if @beta.users.include? @current_user
      flash[:success] = "Removed user #{@current_user.full_name} from #{@beta.name}"
      @beta.users.delete @current_user

      if !@beta.list.nil?
        if list 
          if list.include?(@current_user)
            list.unsubscribe @current_user
            flash[:success] = "Unsubscribed #{@current_user.full_name} from  #{list.name} list"
          else
            flash[:warning] = "#{@current_user.full_name} is not subscribed to #{list.name} list"
          end
        end
      end
      redirect_to :back
    end
  end
end
