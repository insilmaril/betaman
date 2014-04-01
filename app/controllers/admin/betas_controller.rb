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
        @betas_with_lists << { 
          beta: b, 
          added_to_list: r[:added_to_list], 
          dropped_from_list: r[:dropped_from_list], 
          created: r[:created],
          added_to_beta: r[:added_to_beta]
        }
      end
    end
  end

  def check
    # Find betas with downloads
    @betas_with_downloads = DownloadHelper.find_betas_with_downloads
  end

  def inactive_participations
  end
end
