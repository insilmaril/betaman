require 'diary'
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
    @users_employee_added   = []
    @users_employee_dropped = []
    @users_company_changed  = []

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

    attachmate = Company.where( name: "Attachmate").first
    if attachmate.nil?
      flash[:error] = "Couldn't find company 'Attachmate' in database"
      redirect_to admin_path
    end

    netiq = Company.where( name: "NetIQ").first
    if netiq.nil?
      flash[:error] = "Couldn't find company 'NetIQ' in database"
      redirect_to admin_path
    end

    User.all.each do |u|
      if MailHelper.internal_domain?(u.email)
        # Set user role
        if !u.employee?
          u.make_employee
          @users_employee_added << u
          Blog.info "Update roles: Added to employees: #{u.logname}"
          Diary.got_employee_role user: u, actor: @current_user
        end

        # Set users company
        company_changed = false
        if /suse\.(de|com|cz)$/.match(u.email) && u.company != suse
          u.company = suse
          company_changed = true
          @users_company_changed << u
        elsif /novell\.com$/.match(u.email) && u.company != novell
          u.company = novell
          company_changed = true
        elsif /attachmate\.com$/.match(u.email) && u.company != attachmate
          u.company = attachmate
          company_changed = true
        elsif /netiq\.com$/.match(u.email) && u.company != netiq
          u.company = netiq
          company_changed = true
        end
        if company_changed
          @users_company_changed << u
          Diary.company_changed user: u, actor: @current_user
          Blog.info "Update roles:    Company changed: #{u.logname}"
        end
        u.save
      else
        #User is external according to email domain
        if u.employee?
          u.drop_employee
          u.save
          @users_employee_dropped << u
          Blog.info "Update roles: Dropped from employees: #{u.logname}"
          Diary.dropped_employee_role user: u, actor: @current_user
        end
      end
    end
  end
end
