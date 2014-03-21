require 'betaadmin'
require 'download_helper'

class Admin::BetasController < ApplicationController
  def index
    if !@current_user.admin?
      redirect_to root_path
    end
    
    @betas = Beta.all
    @active_betas = Beta.active
    @planned_betas = Beta.planned
    @finished_betas = Beta.finished
  end

  def sync_downloads
    ba = BetaAdmin.new
    ba.login_innerweb(Beta.find(1).novell_iw_user, Beta.find(1).novell_iw_pass)

    @betas_with_downloads = DownloadHelper.find_betas_with_downloads
    @betas_with_downloads.each do |b|
      r = ba.sync_downloads b[:beta]
      b[:added] = r[:added]
      b[:dropped] = r[:dropped]
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
    @betas_with_downloads = DownloadHelper.find_betas_with_downloads
  end

  def update_downloads  # FIXME not used atm
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

  def inactive_participations
  end
end
