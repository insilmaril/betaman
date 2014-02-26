#!/usr/bin/env script/rails runner

require 'betaadmin'
require 'download_helper'

def enable_user(admin, beta, user)
  u_login = ""
  u_login = user.login_name if !user.login_name.blank?
  u_company = ""
  u_company = user.company.name if user.company
  
  umail = "" 
  if !user.alt_email.blank?
    umail = user.alt_email
  else
    umail = user.email
  end

  email_used = admin.add( beta, {email: umail, elogin: user.login_name, company: u_company } )

  return
end

begin
  # Login to any beta hosted at Novell
  beta1=Beta.find(1)
  admin = BetaAdmin.new
  admin.login(beta1.novell_user, beta1.novell_pass)

  # Enable downloads for all current betas in one group
  group = Group.find(3)

  [1,2,3].each do |i|
    beta = Beta.find(i)
    puts "Beta #{beta.name}:"
    group.users.each do |user|
      puts "  Enabling #{user.email}..."
      enable_user(admin, beta, user)
    end
  end

  exit

  betas_with_downloads = DownloadHelper.find_betas_with_downloads
  betas_with_downloads.each do |b|
    puts "* #{b[:beta].name}"

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
      email_used = admin.add( b[:beta], {email: umail, elogin: u.login_name, company: u_company } )
      if email_used != umail
        puts "Alternative email used: #{umail} -> #{email_used}"
        u.alt_email = email_used
        u.save!
      end

    end
  end
end
