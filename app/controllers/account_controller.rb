class AccountController < ApplicationController
  
  before_filter :current_user
  skip_before_filter :login_required

  protect_from_forgery :except => :callback

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

    user = User.find_by_uid uid

    logger.info("*   uid: #{uid}")
    logger.info("*  name: #{name}")
    logger.info("* email: #{email}")
    logger.info("*  prov: #{provider}")

    if user.nil?
      logger.info("* Couldn't find user, creating new")
      user = User.new(:uid => uid)
      user.name = name unless name.blank?
      user.email = email unless email.blank?
      user.save!
      flash[:success] = "New account created!"
    else
      flash[:success] = "You are signed in."
    end
    session[:user_id] = user.id
    redirect_to "http://born.suse.de:4321/"
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
    puts "AUTH HASH"
    request.env['omniauth.auth']
  end
  
  def clear_login
    session[:user_id] = nil
    @current_user = nil
  end

end