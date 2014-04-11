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
  if email_used != umail
    puts "Alternative email used: #{umail} -> #{email_used}"
    user.alt_email = email_used
    user.save!
  end

  return
end

begin
  # Login to any beta hosted at Novell
  beta1=Beta.find(1)
  admin = BetaAdmin.new
  admin.login(beta1.novell_user, beta1.novell_pass)

=begin
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
=end

=begin
  # Enable downloads for spefici user and beta
  user = User.find 1035
  beta = Beta.find 1
  enable_user admin, beta, user
=end

  betas_with_downloads = DownloadHelper.find_betas_with_downloads
  betas_with_downloads.each do |b|
    puts "* #{b[:beta].name}"

    n = 1
    b[:ext_users_without_downloads].each do |user|
      puts "    Enbabling (#{n}/#{b[:ext_users_without_downloads].count}): #{user.logname}"
      n += 1
      enable_user(admin, b[:beta], user)
    end
  end

end
