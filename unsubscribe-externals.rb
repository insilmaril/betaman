#!/usr/bin/env script/rails runner

require 'betaadmin'
require 'download_helper'

begin
  puts "Unbscribing external users of Betas with downloads..."

  betas_with_downloads = DownloadHelper.find_betas_with_downloads
  betas_with_downloads.each do |b|
    puts "* #{b[:beta].name}"

    users = b[:beta].list.users.external

    n = 1
    users.each do |u|
      puts "    Unsubscribing (#{n}/#{users.count}): #{u.logname}"
      b[:beta].list.unsubscribe(u)
      n += 1
    end
    
    #puts "    Sync external list to internal..."
    #b[:beta].list.sync_to_intern
  end
end
