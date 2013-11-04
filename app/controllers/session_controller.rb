require 'mail_helper'

class SessionController < ApplicationController
  before_filter :current_user
  skip_before_filter :login_required

  protect_from_forgery :except => :callback

  def index
  end

  def login
  end

  def logout
    clear_login
    redirect_to root_path
  end
  
  def callback
    uid = auth_hash[:uid]
    name = auth_hash[:info][:name]
    email = auth_hash[:info][:email]
    provider = auth_hash[:provider]

    #raise request.env["omniauth.auth"].to_yaml

    user = User.joins(:accounts).where(accounts: {uid: uid}).first

    logger.info("*   uid: #{uid}")
    logger.info("*  name: #{name}")
    logger.info("* email: #{email}")
    logger.info("*  prov: #{provider}")

    if user.nil?
      logger.info("* Couldn't find user, creating new")
      user = User.new
      user.last_name  = name.split.last unless name.blank?
      user.first_name = name.split.first unless name.blank?
      if email.blank?
        email = 'n.a.'
      end
      user.email = email 
      user.accounts << Account.new(uid: uid)
      user.save!
      UserMailer.admin_mail(
        "Created #{user.full_name}",
        "User ID: #{user.id}\n" +
        "  Email: #{email}\n" +
        "Account: #{uid}"
      ).deliver
      flash[:success] = "New account created for #{user.full_name}"
      if MailHelper.internal_domain?(email)
        user.make_employee
        flash[:info] = "Added role 'employee' for #{user.full_name}"
      end
    else
      logger.info("* Signed in: #{user.accounts.first.uid} URL: #{@url} Cookies: #{@_cookies}")
      flash[:success] = "You are signed in."
      UserMailer.admin_mail("Signed in #{user.full_name}","User ID: #{user.id}").deliver
    end
    session[:user_id] = user.id
    redirect_to dashboard_path
  end

  def failure
    flash[:error] = "Authentication failed, please try again."
    redirect_to root_path
  end

  def current_user
    return @current_user if @current_user

    user_id = session[:user_id]
    if !user_id
      @current_user = nil 
    else
      begin
        @current_user = User.find user_id
      rescue ActiveRecord::RecordNotFound
        @current_user = nil 
      end 
    end 
  end 

  private

  def auth_hash
    request.env['omniauth.auth']
  end
  
  def clear_login
    session[:user_id] = nil
    @current_user = nil
  end

end