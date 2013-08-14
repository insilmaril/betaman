class DashboardController < ApplicationController
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

  def betas_by_status(status)
    if status == 'active'
      return Betas.active
    else
      return Betas.all
    end
  end
end
