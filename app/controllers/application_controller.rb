class ApplicationController < ActionController::Base
  # protect_from_forgery

  def login
    unless user_logged_in?
      redirect_to "/auth/facebook"
    end
  end

  def user_logged_in?
    if session[:user]
      @user = Member.as name: session[:user]
    end
    session[:user] != nil
  end

  helper_method :user_logged_in?
end
