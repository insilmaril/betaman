class Admin::DashboardController < ApplicationController
  def index
    if !@current_user.admin?
      redirect_to root_path
    end
  end
end
