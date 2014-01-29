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
    @duplicates = User.select("email, count(email) as cnt").group(:email).having("count(email) >1").map {|u| u.email}
  end

  def update_roles
    @users_employee_added = []
    @users_employee_dropped = []
    User.all.each do |u|
      if MailHelper.internal_domain?(u.email)
        # User is employee according to email domain
        if !u.employee?
          u.make_employee
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
