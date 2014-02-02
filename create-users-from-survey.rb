#!/usr/bin/env script/rails runner

require 'csv'

def import(file)  

  email_tag   = 'Email Address:'
  company_tag = 'Company:'
  name_tag    = 'Full Name:'
  login_tag   = 'Login:'
  note_tag    = 'Note:'
  address_1_tag       = 'Address 1:'
  address_2_tag       = 'Address 2:'
  address_3_tag       = 'Address 3:'
  address_city_tag    = 'City/Town:'
  address_state_tag   = 'State/Province:'
  address_zip_tag     = 'ZIP/Postal Code:'
  address_country_tag = 'Country:'
  address_phone_tag   = 'Phone Number:'

  companies_created = []
  users_created = []
  users_changed = []

  Blog.info "Import users from #{file}"

  emails_found = []
  CSV.foreach(file, headers: true) do |r|  
    row = r.to_hash
    changed = false

    #Email is the mandatory field
    email = ""
    email = row[email_tag] if row[email_tag]
    if !email.blank?
      # Check for duplicate emails
      if emails_found.include? email
        Blog.warn "  Warning: Ignoring previously found #{email}"
      else
        emails_found << email
       
        # Set email
        user = User.find_by_email(email)
        if !user
          user = User.new
          user.email = email
          user.save!
          users_created << user
          Blog.info "  Created #{user.logname}"
        else
          # Blog.info "  Found #{user.logname}"
        end

        # Set company
        company = ""
        company = row[company_tag] if row[company_tag]
        if !company.blank?
          # Check if company already is there 
          c = Company.find_by_name company
          if !c
            c = Company.create!(name: company)
            user.company = c
            changed = true
            companies_created << c
            Blog.info "    Created company: #{company}"
          else
            if user.company.blank? 
              Blog.info "    Setting company: #{company}"
              user.company = c
              changed = true
            else
              if user.company.name.downcase != company.downcase
                Blog.info "    Changing company: #{user.company.name} -> #{company}"
                user.company = c
                changed = true
              end
            end
          end
        end

        # Set name
        if row[name_tag]
          changed = user.set_full_name( row[name_tag] )
          Blog.info "    Changed name to #{user.full_name}" if changed
        end

        # Set login
        if row[login_tag] && user.login_name != row[login_tag]
          Blog.info "    Changed login_name: #{user.login_name} -> #{row[login_tag]}"
          user.login_name = row[login_tag]
          changed = true
        end

        # Set note by appending, if content not already included in note
        if row[note_tag] 
          if user.note.blank?
            Blog.info "    Wrote new note: #{row[note_tag]}"
            user.note = row[note_tag]
            changed = true
          else
            if !user.note.include? row[note_tag]
              user.note = "#{user.note}\n\n#{row[note_tag]}"
              Blog.info "    Appended note: #{row[note_tag]}"
              changed = true
            end
          end
        end

        # Set Address
        a = Address.new
        a.address1 = row[address_1_tag]  || ''
        a.address2 = row[address_2_tag]  || ''
        a.address3 = row[address_3_tag]  || ''
        a.city     = row[address_city_tag]    || ''
        a.state    = row[address_state_tag]   || ''
        a.zip      = row[address_zip_tag]     || ''
        a.country  = row[address_country_tag] || ''
        a.phone    = row[address_phone_tag]   || ''

        if user.address != a 
          Blog.info "    Updating  address. Phone=#{a.phone}  #{row[address_phone_tag]}"
          Blog.info "    #{row}"
          a.save!
          user.address = a
          changed = true
        end

        # Adding to betas. Uses alias names of betas in DB
        betas = Beta.where("LENGTH(alias) > 0")
        betas.each do |b|
          if row[b.alias]
            Blog.info "    Adding to Beta: #{b.alias}"
            b.users << user
            changed = true
          end
        end
        
        if changed
          user.save!
          Blog.info "  Changed: #{user.logname}"
        end
      end # No duplicate email
    end # email found
  end  # CSV
  return { companies_created: companies_created, users_created: users_created, users_changed: users_changed }
end

begin
  r = import('2014-01-27-for-betaman.csv')
  puts "#{r[:companies_created].count} companies created"
  puts "#{r[:users_created].count} users created"
  puts "#{r[:users_changed].count} users changed"
end