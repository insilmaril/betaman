#!/usr/bin/env script/rails runner

require 'betaadmin'
require 'download_helper'

begin
  ba = BetaAdmin.new
  ba.login_innerweb(Beta.find(1).novell_iw_user, Beta.find(1).novell_iw_pass)

  @betas_with_downloads = DownloadHelper.find_betas_with_downloads
  @betas_with_downloads.each do |b|
    r = ba.sync_downloads b[:beta]
    b[:added] = r[:added]
    b[:dropped] = r[:dropped]
  end
end
