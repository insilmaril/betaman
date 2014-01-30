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
        r = b.sync_downloads_to_intern
        @betas_with_downloads << { beta: b, added: r[:added], dropped: r[:dropped]}
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

  def check
    # Find betas with downloads
    @betas_with_downloads = []
    Beta.all.each do |b|
      if b.has_novell_download?
        missing_dls = []
        b.participations.each do |p|
          if p.downloads_act.blank? && !p.user.employee?
            missing_dls << p.user
          end
        end

        ext_missing_lists = []
        int_missing_lists = []
        b.users.each do |u|
          if !b.list.users.include? u
            if u.employee?
              int_missing_lists << u
            else
              ext_missing_lists << u
            end
          end
        end

        @betas_with_downloads << { 
          beta: b, 
          ext_users_without_downloads: missing_dls,
          int_users_without_list: int_missing_lists,
          ext_users_without_list: ext_missing_lists
        }
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
