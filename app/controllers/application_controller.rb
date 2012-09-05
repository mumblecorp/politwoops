class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user_session, :current_user

  helper TweetsHelper
  
  protected
  
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "politwoops" && password == "hackdeoverheid"
    end
  end
    
  private

  # needs to become more dynamic somehow
  def set_locale
    # not sure what this does
    I18n::Backend::Simple.send(:include, I18n::Backend::Flatten)
    I18n.locale = "en"
  end
  
  def set_twitter
    Twitter.configure do |config|
      config.consumer_key       = 'f8Sgj9idhBH7mPRoYdFbxQ'
      config.consumer_secret    = '11KcMSu13ZIL2UTh8gos9mve5cgWiysFYSqRW4jBQ'
      config.oauth_token        = '260405786-7dd6mKfPdWiXPqczc3k3qYtFrJGHqC8Mo2HyJYp6'
      config.oauth_token_secret = 'mWPfNcKCUSq6i6XVScqWg22OFN8h3PzfK8LxIRL6Y'
    end
    @twitter_client = Twitter::Client.new
  end
  
  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
  
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end
  
  def require_user
    unless current_user
      store_location
      flash[:notice] = t(:require_user, :scope => [:politwoops, :users])
      redirect_to new_user_session_url
      return false
    end
  end

  def require_admin_user 
    unless current_user && (current_user.is_admin == 1)
      store_location 
      flash[:notice] = t(:require_admin_user, :scope => [:politwoops, :users]) 
      redirect_to new_user_session_url
      return false 
    end 
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = t(:require_no_user, :scope => [:politwoops, :users])
      redirect_to account_url
      return false
    end
  end

  def require_admin_or_no_user
    if current_user && (current_user.is_admin != 1)
      store_location
      flash[:notice] = t(:require_no_user, :scope => [:politwoops, :users])
      redirect_to account_url
      return false
    end
  end
  
  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
end