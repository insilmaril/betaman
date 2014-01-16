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

    logger.info("*   uid: #{uid}")
    logger.info("*  name: #{name}")
    logger.info("* email: #{email}")
    logger.info("*  prov: #{provider}")

    user = User.joins(:accounts).where(accounts: {uid: uid}).first

    if user.nil?
      # No user account found for this provider

      # Check if user already exists without account, e.g. via list
      # subscription

      if email.blank? # FIXME better validate email
        flash[:error] = "No email provided by #{provider}. Please check your account seetings!"
        email = ''
      end

      user = User.find_by_email(email)

      if user.nil?
        # No account and no user with this email => Create user

        logger.info("* Couldn't find user, creating new")
        user = User.new
        user.last_name  = name.split.last unless name.blank?
        user.first_name = name.split.first unless name.blank?
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
        # UserMailer.welcome_mail(user)
        Blog.info "Session controller: New account created for #{user.logname}" 

        if MailHelper.internal_domain?(email) # FIXME remove this automatism
          user.make_employee
          msg = "Session controller Added role 'employee' for #{user.logname}"
          flash[:info] = msg
          Blog.info msg
        end

      else
        # No account, but user with same email
        # Check, if user has logged in before

        if user.accounts.count > 0
          # User account for given provider does not exist,
          # but a user for the email exists and that user
          # already has a different account
          # => notify user and admin, but don't login # FIXME better send validation link
          flash[:error] = "There is already a user with #{email}, admin has been notified"
          UserMailer.admin_mail(
            "Signin problem",
            "openID provided:\n" +
            "    uid: #{uid}\n" + 
            "   name: #{name}\n" + 
            "  email: #{email}\n" +
            "   prov: #{provider}\n\n" + 
            "User exists with:\n" +
            "  email: #{user.email}\n" +
            "   name: #{user.full_name}\n" + 
            "     ID: #{user.id}").deliver
          redirect_to root_path
          return
        else
          # User account for given provider does not exist,
          # but a user for the email exists and that user
          # has not logged in yet (has no account)
          # This happens when user is created from analyzing mailing
          # lists (which are administered by Beta admin)
          # => notify user and admin, and add account # FIXME better send validation link

          user.accounts << Account.new(uid: uid)
          user.save!
          UserMailer.admin_mail(
            "Account created for existing user",
            "    email: #{user.email}\n" +
            "     name: #{user.full_name}\n" +
            "       ID: #{user.id}").deliver
        end
      end
    end
    # sign in
    logger.info("* Signed in: #{user.accounts.first.uid} URL: #{@url} Cookies: #{@_cookies}")
    flash[:success] = "You are signed in."

    # For the time being tell admin
    UserMailer.admin_mail("Signed in #{user.email}","User ID: #{user.id}").deliver
    Blog.info "Signed in", user
    
    session[:user_id] = user.id
    redirect_to dashboard_path
  end

  def failure
    flash[:error] = "Authentication failed, please try again."
      
    msg1 = "User authentication failed"
    msg2 = "    URL: #{session['omniauth.params']['openid_url'].to_s}"
    Blog.warn msg1 + msg2
    UserMailer.admin_mail(msg1, msg2).deliver
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