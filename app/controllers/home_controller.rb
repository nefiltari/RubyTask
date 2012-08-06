# This is the Controller for the index page ("home") and several important views

class HomeController < ApplicationController

  # GET /home
  # GET /home.json
  def index
    # User-Control needed for the following: 
    # redirect_to '/' unless User.logged_in?

    respond_to do |format|
      format.html # index.html.erb
    end
  end

end
