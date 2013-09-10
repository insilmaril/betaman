class Admin::BetasController < ApplicationController
  def index
    if !@current_user.admin?
      redirect_to root_path
    end
    
    @betas = Beta.all
  end
end
