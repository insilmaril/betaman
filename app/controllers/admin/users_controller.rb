class Admin::UsersController < ApplicationController
  def index
    if !@current_user.admin?
      redirect_to root_path
    end
    
    @users = User.all
  end
end
