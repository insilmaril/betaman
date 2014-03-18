require 'mail_helper'

class Admin::UsersController < ApplicationController
  def index
    if !@current_user.admin?
      redirect_to root_path
    end
    
    @users = User.all
  end

  def show
  end

  def duplicate_emails
    a = User.select(:email).map{|u| u.email.downcase}
    @duplicates = a.select{|e| a.count(e) > 1}.uniq
  end

  def update_roles
    @users_employee_added = []
    @users_employee_dropped = []

    suse = Company.where( name: "SUSE").first
    if suse.nil?
      flash[:error] = "Couldn't find company 'SUSE' in database"
      redirect_to admin_path
    end

    novell = Company.where( name: "Novell").first
    if novell.nil?
      flash[:error] = "Couldn't find company 'Novell' in database"
      redirect_to admin_path
    end

    User.all.each do |u|
      if MailHelper.internal_domain?(u.email)
        # User is employee according to email domain
        if !u.employee?
          u.make_employee
          if /suse\.(de|com|cz)$/.match(u.email)
            u.company = suse
          elsif /novell\.com$/.match(u.email)
            u.company = suse
          end

          u.save
          @users_employee_added << u
          Blog.info "Update roles: Added to employees: #{u.id} - #{u.email}"
        end
      else
        #User is external according to email domain
        if u.employee?
          u.drop_employee
          u.save
          @users_employee_dropped << u
          Blog.info "Update roles: Dropped from employees: #{u.id} - #{u.email}"
        end
      end
    end
  end
end
