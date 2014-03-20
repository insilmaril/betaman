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
    group = Group.find(params[:id])
    users_created, companies_created = group.import(params[:file])  
    flash[:success] = "Finished importing: Created #{users_created} users and #{companies_created} companies"

    # Check, if emails of users in group also exist outside of group
    duplicate_mails = false
    group.users.each do |guser|
      email = guser.email || ''
      existing_users = User.where("lower(email) = ?", email)
      existing_users.each do |user|
        if user && ! group.users.include?(user)
          duplicate_mails = true
        end
      end
    end
    if duplicate_mails
      flash[:warning] = "Warning: Found duplicate emails!"
    end
    
    redirect_to admin_group_path(group)
  end

  def merge_users
    # Check if group user has a similar user in DB 
    # out of group, with same email
    #
    # In that case
    #  - update that DB user with the contact info of group user
    #  - replace group user by DB user


    group = Group.find(params[:id])
    Blog.info "Merge group #{group.name} to DB:", @current_user

    group_users_added = []
    group_users_deleted = []
    group_users_unchanged = []
    group_users_duplicates = []

    group.users.each do |guser|
      group_user_email = guser.email.downcase || ''
      existing_users = User.where("lower(email) = ?", group_user_email)
      existing_users.each do |user|
        if !group.users.include?(user)

          # The group might have duplicate users
          if group_users_added.include?(user)
            Blog.info "  Duplicate user in group: #{guser.logname}"
            group_users_duplicates << guser
          else
            user.copy_contact_info guser   
            user.save!
            group_users_added << user
            # In theory there should be no more than one existing 
            # user in the DB (outside of group). So only delete guser
            # once...
            if !group_users_deleted.include?(guser)
              group_users_deleted << guser
            end
          end
        end
      end
    end

    # Don't delete duplicates for now, better do that manually
    # to edit contact info
    group_users_delete = group_users_deleted - group_users_duplicates

    group_users_unchanged = group.users - group_users_deleted - group_users_added

    group_users_added.each do |user|
      Blog.info "      Added: #{user.logname}"
      group.users << user
    end

    group_users_deleted.each do |guser|
      Blog.info "    Deleted: #{guser.logname}"
      guser.delete
    end

    group_users_unchanged.each do |guser|
      Blog.info "  Unchanged: #{guser.logname}"
    end

    group_users_duplicates.each do |guser|
      Blog.info " Duplicates: #{guser.logname}"
    end
    group.reload

    flash[:success] = "Finished merge: Deleted #{group_users_deleted.count} and updated #{group_users_added.count} users in group #{group.name}. Unchanged #{group_users_unchanged.count} users in group."

    flash[:warning] = "Found duplicates within group: #{group_users_duplicates.map{|u| u.logname}.join(',')}"

    redirect_to admin_group_path(group)
  end

  def add_to_beta
    group = Group.find(params[:id])
    beta  = Beta.find(params[:beta_id])
    existing_users = []
    added_users = []
    group.users.each do |user|
      if beta.users.include?(user)
        existing_users << user
      else
        added_users << user
        beta.users << user
      end
    end

    Blog.info "Add group #{group.name}  to beta #{beta.name}:", @current_user
    existing_users.each do |user|
      Blog.info "  Already in beta: #{user.logname}:"
    end
    added_users.each do |user|
      Blog.info "    Added to beta: #{user.logname}:"
    end
      


    flash[:success] = "Found #{existing_users.count} users in #{beta.name}, added #{added_users.count} users."
    redirect_to admin_group_path(group)
  end
end
