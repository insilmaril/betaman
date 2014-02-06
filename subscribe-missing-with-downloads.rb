#!/usr/bin/env script/rails runner

require 'betaadmin'
require 'download_helper'

begin
  puts "Subscribing external users with downloads and internal users..."

  betas_with_downloads = DownloadHelper.find_betas_with_downloads
  betas_with_downloads.each do |b|
    puts "* #{b[:beta].name}"

    users = ( b[:ext_users_without_list] & b[:users_with_downloads] ) + b[:int_users_without_list]

    n = 1
    users.each do |u|
      puts "    Subscribing (#{n}/#{users.count}): #{u.logname}"
      b[:beta].list.subscribe(u)
      n += 1
    end
    
    puts "    Sync external list to internal..."
    b[:beta].list.sync_to_intern
  end
end
