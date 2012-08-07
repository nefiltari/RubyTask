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


  def search
    query = params[:query]

    @org_results = Organisation.search query
    @proj_results = Project.search query

    respond_to do |format|
      format.html{render layout: false} # index.html.erb
    end
  end

end
