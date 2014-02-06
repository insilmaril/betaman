#!/usr/bin/env script/rails runner

require 'betaadmin'
require 'download_helper'

begin
=begin
  u = User.find 427
  u_login = ""
  u_login = u.login_name if !u.login_name.blank?
  u_company = ""
  u_company = u.company.name if u.company
  
  b = Beta.find 2
  admin = BetaAdmin.new( b.novell_user, b.novell_pass, b.novell_id)
  admin.login

  umail = "" 
  if !u.alt_email.blank?
    umail = u.alt_email
  else
    umail = u.email
  end

  puts "Trying to add #{umail}"
  email_used = admin.add( {email: umail, elogin: u.login_name, company: u_company } )
  puts "Added: #{email_used}"
  if email_used != u.email
    u.alt_email = email_used
    u.save!
  end
  exit
=end

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
      
      umail = "" 
      if !u.alt_email.blank?
        umail = u.alt_email
      else
        umail = u.email
      end
     # puts "Trying to add #{umail}"
      email_used = admin.add( {email: umail, elogin: u.login_name, company: u_company } )
      if email_used != umail
        puts "Alternative email used: #{umail} -> #{email_used}"
        u.alt_email = email_used
        u.save!
      end

    end
  end
end
