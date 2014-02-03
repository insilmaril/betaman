#!/usr/bin/env script/rails runner

require 'betaadmin'
require 'download_helper'

begin
  betas_with_downloads = DownloadHelper.find_betas_with_downloads
  betas_with_downloads.each do |b|
    puts "* #{b[:beta].name}"

    users = ( b[:ext_users_without_list] & b[:users_with_downloads] ) + b[:int_users_without_list]

    n = 1
    users.each do |u|
      puts "    Subscribing (#{n}/#{users.count}): #{u.logname}"
      n += 1
    end
  end
end
