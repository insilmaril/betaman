class Admin::CompaniesController < ApplicationController
  def index
    if !@current_user.admin?
      redirect_to root_path
    end
    
    @companies = Company.all
  end
end
