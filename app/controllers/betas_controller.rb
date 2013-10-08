class BetasController < ApplicationController
  def init_instance_variables
    @beta = Beta.find(params[:id])
  end

  def index
    @betas = Beta.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @betas }
    end
  end

  def edit
    if @current_user.admin?
      init_instance_variables
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
    init_instance_variables
    @users = @beta.users

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @beta }
    end
  end

  def update
    init_instance_variables

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
      init_instance_variables
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
    init_instance_variables

    @users = @beta.users
  end

  def nousers
    users
    @nousers = User.all - @users
  end

  def add_user
    init_instance_variables
    user = User.find(params[:user_id])

    if @current_user.admin?
      if !@beta.users.include? user
        @beta.users << user
        flash[:success] = "Added #{user.id} to #{@beta.name}!"
      else
        flash[:warning] = "#{user.full_name} is already member of #{@beta.name}!"
      end

      redirect_to :back
    end
  end

  def add_select_users
    init_instance_variables
    if @current_user.admin? 
      nousers
    end
  end

  def add_multiple_users
    init_instance_variables
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
=begin
      if !@beta.users.include? user
        @beta.users << user
        flash[:success] = "Added user #{user.id} from beta #{@beta.name}!"
      else
        flash[:warning] = "User #{user.full_name} is already member of beta #{@beta.name}!"
      end
=end
    redirect_to beta_path(@beta)
 end

  def remove_user
    init_instance_variables

    user = User.find(params[:user_id])

    if @current_user.admin?
      if @beta.users.include? user
        @beta.users.delete(user)
        flash[:success] = "Removed user #{user.id} from beta #{@beta.name}!"
      else
        flash[:warning] = "User #{user.full_name} is not a member of beta #{@beta.name}!"
      end
      redirect_to :back
    end
  end
end
