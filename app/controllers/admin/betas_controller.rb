class Admin::BetasController < ApplicationController
  def index
    if !@current_user.admin?
      redirect_to root_path
    end
    
    @betas = Beta.all
  end

  def sync_downloads
    # Find betas with downloads
    @betas_with_downloads = []
    Beta.all.each do |b|
      if b.has_novell_download?
        ctotal, cadded, cdropped = b.sync_downloads_to_intern
        @betas_with_downloads << { beta: b, total: ctotal, added: cadded, dropped: cdropped}
      end
    end
  end

  def sync_lists
    # Find betas with lists
    @betas_with_lists = []
    Beta.all.each do |b|
      if !b.list.blank?
        r = b.list.sync_to_intern
        @betas_with_lists << { beta: b, added: r[:added], dropped: r[:dropped], created: r[:created] }
      end
    end
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

        beta.sync_downloads_to_intern
        
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
