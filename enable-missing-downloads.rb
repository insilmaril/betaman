#!/usr/bin/env script/rails runner

require 'betaadmin'
require 'download_helper'

begin
  u = User.find 380
  u_login = ""
  u_login = u.login_name if !u.login_name.blank?
  u_company = ""
  u_company = u.company.name if u.company
  
  b = Beta.find 1
  admin = BetaAdmin.new( b.novell_user, b.novell_pass, b.novell_id)
  admin.login

  email_used = admin.add( {email: u.email, elogin: u.login_name, company: u_company } )
  puts "Added: #{email_used}"
  if email_used != u.email
    u.alt_email = email_used
    u.save!
  end

  exit

  betas_with_downloads = DownloadHelper.find_betas_with_downloads
  betas_with_downloads.each do |b|
    puts "* #{b[:beta].name}"

    admin = BetaAdmin.new( b[:beta].novell_user, b[:beta].novell_pass, b[:beta].novell_id)
    admin.login

    n = 1
    b[:ext_users_without_downloads].each do |u|
      puts "    Enbabling (#{n}/#{b[:ext_users_without_downloads].count}): #{u.logname}"
      n += 1

      u_login = ""
      u_login = u.login_name if !u.login_name.blank?
      u_company = ""
      u_company = u.company.name if u.company
      
      email_used = admin.add( {email: u.email, elogin: u.login_name, company: u_company } )
      if email_used != u.email
        puts "Alternative email used: #{u.email} -> #{email_used}"
        u.alt_email = email_used
        u.save!
      end

    end
  end
end
