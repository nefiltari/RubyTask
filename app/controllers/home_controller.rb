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

    require 'httmultiparty'

    #class

    val = {
      access_token: session[:access_token].to_s,
      message: "You are invited to the following #{params[:type].capitalize}.",
      link: (params[:type] == "project") ? "" : "http://lvh.me:3000/#{params[:type]}/#{params[:name]}",
      name: group.name,
      description: group.description
    }

    pp val

    url = URI.parse("https://graph.facebook.com/feed")

    req = Net::HTTP::Post::Multipart.new "#{url.path}?#{val.to_query}", "file" => nil
    n = Net::HTTP.new(url.host, url.port)
    n.use_ssl = true
    n.verify_mode = OpenSSL::SSL::VERIFY_NONE
    n.start do |http|
      http.request(req)
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
