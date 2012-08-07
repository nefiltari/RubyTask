# This is the Controller for the index page ("home") and several important views

class HomeController < ApplicationController
  before_filter :login
  
  # GET /home
  # GET /home.json
  def index

    respond_to do |format|
      format.html # index.html.erb
    end
  end

end
