class Admin::GroupsController < ApplicationController
  before_filter :admin_required

  def index
    @groups = Group.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @groups }
    end
  end

  def edit
    if @current_user.admin?
      @group = Group.find(params[:id])
    else
      flash[:error] = "Access denied: Editing Group"
      redirect_to root_path
    end
  end

  def new
    if @current_user.admin?
      @group = Group.new

      respond_to do |format|
        format.html 
        format.json { render json: @group }
      end
    else
      flash[:error] = "Access denied: New Group"
      redirect_to root_path
    end
  end

  def create
    @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        flash[:success] = "Created group #{@group.name}"
        format.html { redirect_to admin_groups_path}
        format.json { render json: @group, status: :created, location: @group }
      else
        flash[:warning] = "Failed to create group #{@group.name}"
        format.html { render action: "new" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @group = Group.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @group }
    end
  end

  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:success] = "Updated group #{@group.name}"
        format.html { redirect_to admin_groups_path }
        format.json { head :no_content }
      else
        flash[:warning] = "Failed to update group #{@group.name}"
        format.html { render action: "edit" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @current_user.admin?
      group = Group.find(params[:id])
      group.destroy
      flash[:success] = "Deleted group #{group.name}"

      respond_to do |format|
        format.html { redirect_to admin_groups_path }
        format.json { head :no_content }
      end
    else
      flash[:error] = "Access denied: Delete group #{group.name}"
      redirect_to root_path
    end
  end

  def users
    @group = Group.find(params[:id])
    @users = @group.users.order :email
  end

  def nousers
    users
    @nousers = User.all - users
  end

  def add_user
    @group = Group.find(params[:id])
    user = User.find(params[:user_id])

    if @current_user.admin?
      if !@group.users.include? user
        @group.users << user
        flash[:success] = "Added #{user.full_name} to #{@group.name}"
      else
        flash[:warning] = "#{user.full_name} is already member of #{@group.name}"
      end

      redirect_to :back
    end
  end

  def add_select_users
    @group = Group.find(params[:id])
    if @current_user.admin? 
      nousers
    end
  end

  def add_multiple_users
    @group = Group.find(params[:id])
    if @current_user.admin? 
      if defined?(params[:user_ids])
        n = params[:user_ids].count
        s = view_context.pluralize(n, 'member')
        flash[:success] = "Added #{s} to #{@group.name}"
        params[:user_ids].each do |user|
          @group.users << User.find(user)
        end
      else
        flash[:warning] = "No Params defined"
      end
    end
    redirect_to admin_group_path(@group)
  end

  def remove_user
    @group = Group.find(params[:id])

    user = User.find(params[:user_id])

    if @current_user.admin?
      if @group.users.include? user
        @group.users.delete(user)
        flash[:success] = "Removed #{user.full_name} from #{@group.name}"
      else
        flash[:warning] = "User #{user.full_name} is not a member of  #{@group.name}!"
      end
      redirect_to :back
    end
  end

  def upload
    @group = Group.find(params[:id])
    users_created, companies_created = @group.import(params[:file])  
    flash[:success] = "Finished importing: Created #{users_created} users and #{companies_created} companies"
    redirect_to admin_group_path(@group)
  end

  def merge_users
    group = Group.find(params[:id])
    update_users = []
    delete_members = []
    group.users.each do |guser|
      existing_users = User.where("lower(email) = ?", guser.email.downcase)
      existing_users.each do |user|
        if user && ! group.users.include?(user)
          user.copy guser
          user.save!
          update_users << user
          delete_members << guser
        end
      end
    end

    update_users.each do |user|
      group.users << user
    end

    delete_members.each do |guser|
      group.users.delete guser
    end

    flash[:success] = "Finished merging: Merged #{} and updated #{update_users.count} users"
    redirect_to :back
  end
end
