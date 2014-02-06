#!/usr/bin/env script/rails runner

require 'download_helper'

begin
  @betas_with_downloads = DownloadHelper.find_betas_with_downloads(true)
end
