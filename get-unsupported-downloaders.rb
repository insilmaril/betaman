#!/usr/bin/env script/rails runner

require 'download_helper'

begin
  if ARGV.count != 1
    puts "Please provide filename for out of csv file!"
    exit
  end
  filename = ARGV[0]

  list = {}

  betas_with_downloads = DownloadHelper.find_betas_with_downloads()
  betas_with_downloads.each do |b|
    b[:users_with_downloads].each do |u|
      if !u.employee?
        # Mark that support has been requested
        u.participations.where("beta_id = ?",b[:beta].id).each do |p|
          if p.support_req.blank? 
            # Add hash with selected beta into hash, which contains user
            # information
            list[u.id] ||= {}
          
            list[u.id][:betas] ||= []
            list[u.id][:betas] << b[:beta].alias
            
            p.support_req = true
            p.save!
          end
        end
      end # u.external?
    end
  end

  body = ""
  header = "ID,email,alt_email,Name,login,Betas,Company\n"

  list.keys.sort.uniq.each do |k|
    u = User.find(k)
    body += "#{u.id}"
    body += ",#{u.email}"
    body += ",#{u.alt_email}"
    body += ",#{u.full_name}"
    body += ",#{u.login_name}"
    body += ",\"#{list[u.id][:betas].uniq.join(',')}\""

    company  = ","
    company += u.company.name if !u.company.blank?
    body += company
    body += "\n"
  end

  puts body
  
  # Write csv file
  File.open( filename, 'w') do |f|
    f.write header
    f.write body
  end
end
