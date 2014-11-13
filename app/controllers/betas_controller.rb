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
      beta = Beta.new
      beta.name  = "New beta"
      beta.begin = Date.today
      beta.end   = Date.today

      if beta.save!
        Blog.info "Created new beta #{beta.id}", @current_user
        redirect_to edit_beta_path(beta)
      else
        Blog.error "Creating new beta failed", @current_user
        redirect_to root_path(beta)
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
        msg = "Created beta #{@beta.name}"
        flash[:success] = msg
        Blog.info msg, @current_user
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
    @milestones = @beta.milestones.order('date ASC')
    @urls = @beta.urls

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @beta }
    end
  end

  def update
    @beta = Beta.find(params[:id])

    respond_to do |format|
      if @beta.update_attributes(params[:beta])
        msg = "Updated beta #{@beta.name}"
        flash[:success] = msg
        Blog.info msg, @current_user

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
      msg = "#{@beta.name} deleted"
      flash[:success] = msg
      Blog.info msg, @current_user

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
      format.json { render json: UsersDatatable.new(view_context, {users: @users} ) }
    end
  end

  def users_external
    @beta = Beta.find(params[:id])
    @users = @beta.users.external
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: UsersDatatable.new(view_context, {users: @users} ) }
    end
  end

  def init_nousers
    @nousers = User.all - @beta.users
  end

  def add_user
    @beta = Beta.find(params[:id])
    user = User.find(params[:user_id])

    if @current_user.admin?
      if @beta.add_user user, @current_user
        msg = "Added #{user.full_name} to #{@beta.name}"
        flash[:success] = msg
        Blog.info msg, @current_user
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

        ulist = []
        params[:user_ids].each do |user|
          u = User.find(user)
          if (u)
            @beta.users << u
            ulist << "#{u.id} (#{u.email})"
            Diary.added_user_to_beta user: u, beta: @beta, actor: @current_user
          end
        end
        flash[:success] = "Added #{s} to #{@beta.name}"
        Blog.info "Added to #{@beta.name}: #{ulist.join(',')}", @current_user
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
      Blog.info "Adding list subscribers from #{list.name} to #{@beta.name}:", @current_user
      added.each {|u| Blog.info "  Added: #{u}"}
    end
    redirect_to beta_path(@beta)
  end

  def remove_user
    @beta = Beta.find(params[:id])

    user = User.find(params[:user_id])

    if @current_user.admin?
      if @beta.remove_user user, @current_user
        msg = "Removed #{user.full_name} from #{@beta.name}"
        flash[:success] = msg
        Blog.info msg, @current_user
      else
        flash[:warning] = "User #{user.full_name} is not a member of beta #{@beta.logname}!"
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
        msg = "Added list #{newlist.name} to #{beta.name}"
        flash[:success] = msg
        Blog.info msg, @current_user
      end
    end
    redirect_to :back
  end

  def remove_list
    if @current_user.admin?
      beta = Beta.find(params[:id])
      if beta.list
        msg = "Removed list #{beta.list.name} from  #{beta.name}"
        flash[:success] = msg
        Blog.info msg, @current_user
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
      msg = "Added #{@current_user.full_name} to #{@beta.name}"
      flash[:success] = msg
      @beta.users << @current_user
      Blog.info msg, @current_user
      UserMailer.admin_mail(
        "User #{@current_user.logname} joined Beta #{@beta.name}",
        "    email: #{@current_user.email}\n" +
        "     name: #{@current_user.full_name}\n" +
        "       ID: #{@current_user.id}\n" +
        "Please adjust list subscriptions manually").deliver
    end
    Diary.joined_beta user: @current_user, beta: @beta

    redirect_to :back
  end

  def leave
    @beta = Beta.find(params[:id])
    if @beta.users.include? @current_user
      flash[:success] = "Removed user #{@current_user.full_name} from #{@beta.name}"
      @beta.users.delete @current_user
      Blog.info "#{@current_user.logname} left #{@beta.name}", @current_user

      UserMailer.admin_mail(
        "User #{@current_user.logname} left Beta #{@beta.name}",
        "    email: #{@current_user.email}\n" +
        "     name: #{@current_user.full_name}\n" +
        "       ID: #{@current_user.id}\n" +
        "Please adjust list subscriptions manually").deliver
    end

    Diary.left_beta user: @current_user, beta: @beta

    redirect_to :back
  end
end
