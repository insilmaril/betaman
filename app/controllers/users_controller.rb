require 'mail_helper'

class UsersController < ApplicationController

#  before_filter :employee_required

  def init_instance_variables
    @user = User.find(params[:id])
    @betas = @user.betas
    @available_betas  = Beta.not_finished - @betas
    @groups = @user.groups
    @available_groups = Group.all - @groups
    @active_betas = @betas.active
    @planned_betas = @betas.planned
    @finished_betas = @betas.finished 
    @available_finished_betas = Beta.finished - @betas

    @available_lists = List.all - @user.lists
  end
  
  # GET /users
  # GET /users.json
  def index
    if @current_user.employee? || @current_user.admin?
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: UsersDatatable.new(view_context) }
      end
    else
      redirect_to root_path
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @users = User.all
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  def select
  end

  # GET /users/new
  # GET /users/new.json
  def new
    if @current_user.admin?
      user = User.new

      if user.save!
        Blog.info "Created new user #{user.logname}", @current_user
        redirect_to edit_user_path(user)
      else
        respond_to do |format|
          format.html # new.html.erb
          format.json { render json: @user }
        end
      end
    else
      flash[:error] = "Access denied: New user"
      redirect_to root_path
    end
  end

  # GET /users/1/edit
  def edit
    init_instance_variables
    @user = User.find(params[:id])

    if @current_user.admin? || @user == @current_user
      @finished_betas = Beta.finished
    else
      flash[:error] = "Access denied: Editing user"
      redirect_to root_path
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])
    @address = @user.address

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    new_email = params[:user][:email]
    if new_email != @user.email
      Blog.info "User changed mail: #{@user.email} -> #{new_email}", @current_user
      UserMailer.admin_mail(
        "Updated email address: #{@user.full_name}",
        " Email old: #{@user.email}\n" +
        " Email new: #{new_email}\n" +
        "        ID: #{@user.id}"
      ).deliver
    end
    respond_to do |format|
      if @user.update_attributes(params[:user])
      msg = "#{@user.logname} has been updated"
      Blog.info msg, @current_user
      flash[:success] = msg
        format.html { redirect_to edit_user_path(@user) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    if @current_user.admin?
      @user = User.find(params[:id])
      Blog.info "Deleted #{@user.logname}", @current_user
      @user.destroy

      respond_to do |format|
        format.html { redirect_to users_url }
        format.json { head :no_content }
      end
    else
      flash[:error] = "Access denied: Delete User"
      redirect_to root_path
    end
  end

  def betas
    init_instance_variables
  end

  def add_beta
    init_instance_variables
    beta = Beta.find(params[:beta_id])
    if !@betas.include? beta
      @betas << beta
      msg = "#{@user.id} (#{@user.email}) added to Beta #{beta.name}"
      flash[:success] = msg
      Blog.info msg, @current_user
    else
      flash[:warning] = "#{@user.full_name} is already participant of #{beta.name}"
    end

    redirect_to :back
  end

  def remove_beta
    init_instance_variables
    beta = Beta.find(params[:beta_id])
    beta.users.delete(@user)
    msg = "#{@user.logname} removed from #{beta.logname}" 
    flash[:success] = msg
    Blog.info msg, @current_user
    redirect_to :back
  end

  def add_address
    user = User.find(params[:id])
    if user.address
      flash[:error] = "#{user.full_name} already has address #{user.address.id}"
    else
      a = Address.create
      user.address = a
      user.save
      msg = "Created address #{a.id} for user #{user.logname}"
      flash[:success] = msg
      Blog.info msg, @current_user
      redirect_to :back
    end
  end

  def edit_participation
    @user = User.find(params[:id])
    @participation = Participation.find(params[:participation_id] )

    if @current_user.admin? || @user == @current_user
      @finished_betas = Beta.finished
    else
      flash[:error] = "Access denied: Editing user participation"
      redirect_to root_path
    end
  end

  def update_participation
    Blog.info "BM: params: #{params}"
    user = User.find(params[:id])
    note_new = params[:note_new]
    participation = Participation.find(params[:participation_id] )
    if participation 
      if
        participation.note != note_new
        participation.note = note_new
      end
      participation.support_req = params[:support_req]
      participation.support_act = params[:support_act]
      participation.save
    end
    redirect_to edit_user_path(user)
  end
end
