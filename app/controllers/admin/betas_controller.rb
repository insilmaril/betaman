class Admin::BetasController < ApplicationController
  def index
    if !@current_user.admin?
      redirect_to root_path
    end
    
    @betas = Beta.all
  end

  def update_downloads
    # Find betas with downloads
    @betas = []
    @users_added = {}
    Beta.all.each do |beta|
      if beta.has_novell_download?
        Blog.info "Beta #{beta.name} - Update downloads:"

        @betas << beta
        @users_added[beta.id] = []

        #FIXME beta.update_downloads
        
        # Find beta users, who are external and should have download
        beta.users.external.each do |user|
          p = user.participations.where("beta_id = ? AND (downloads_act IS NULL OR downloads_act = false)", beta.id)
          if p.count > 0
            Blog.info "  #{user.id} #{user.email}: Download missing"
            @users_added[beta.id] << user
          else
            Blog.info "  #{user.id} #{user.email}: Download ok"
          end
        end
      end
    end

  end
end
