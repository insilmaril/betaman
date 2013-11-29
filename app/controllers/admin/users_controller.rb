class Admin::UsersController < ApplicationController
  def index
    if !@current_user.admin?
      redirect_to root_path
    end
    
    @users = User.all
  end

  def show
  end

  def duplicate_emails
    @duplicates = User.select("email, count(email) as cnt").group(:email).having("count(email) >1").map {|u| u.email}
  end
end
