class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :current_user
  before_filter :login_required  
 
  private

  def login_required
    if current_user
      return true
    else
      store_location
      flash.keep
      redirect_to :controller=>"session", :action =>"login"
      return false
    end
  end

  def employee_required
    if current_user && current_user.employee?
      return true
    else
      redirect_to root_path
    end
  end

  def admin_required
    if current_user && current_user.admin?
      return true
    else
      redirect_to root_path
    end
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
  
  protected
  
  def redirect_back_or_default default = "/"
    redirect_to session[:return_to] || default
    session[:return_to] = nil
  end 

  def store_location 
    session[:return_to] = request.fullpath
  end

  def keyword_tokens
    required_parameters :q
    render json: Keyword.find_keyword(params[:q])
  end

end
