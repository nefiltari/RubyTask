class SessionsController < ApplicationController

  def new
    unless session[:user]
      respond_to do |format|
        format.html
      end
    else
      redirect_to root_path, notice: "Already logged in!"
    end
  end

  def create
    auth_hash = request.env['omniauth.auth']
    session[:user] = auth_hash
    #redirect_to root_path, notice: "Hello #{session[:user][:info][:name]}"
    render text: auth_hash.inspect
  end

  def failure
    render text: "Error"
  end
end
