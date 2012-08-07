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

  def invite
    friend = Member.as name: params[:id]
    group = nil
    if params[:type] == "project"
      group = Project.as name: params[:name]
    else
      group = Organisation.as name: params[:name]
    end

    require 'net/http'
    uri = URI('https://graph.facebook.com/#{params[:id]}/feed')
    res = Net::HTTP.post_form(
      uri, 
      'access_token' => session[:access_token].to_s, 
      'message' => "You are invited to the following #{params[:type].capitalize}.",
      'link' => (params[:type] == "project") ? "" : organisation_view_url(params[:name]),
      'name' => group.name,
      'description' => group.description
    )
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
