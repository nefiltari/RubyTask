# This is the Controller for the index page ("home") and several important views

class HomeController < ApplicationController
  before_filter :login

  def index
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def invite
    friend = Member.as name: params[:id]

    group = nil
    group = Organisation.as name: params[:name]

    group.add_member friend, Ruta::Role.administrator

    require 'net/http/post/multipart'
    require 'mime/types'
    require 'net/https'

    val = {
      access_token: session[:access_token].to_s,
      message: "You are invited to the following #{params[:type].capitalize} via RubyTask.",
      link: (params[:type] == "project") ? "" : "http://lvh.me:3000/#{params[:type]}s/#{params[:name]}",
      name: group.name,
      caption: "rubytask.org",
      description: group.description
    }

    url = URI.parse("https://graph.facebook.com/#{params[:id]}/feed")

    req = Net::HTTP::Post::Multipart.new "#{url.path}?#{val.to_query}", "file" => nil
    n = Net::HTTP.new(url.host, url.port)
    n.use_ssl = true
    n.verify_mode = OpenSSL::SSL::VERIFY_NONE
    n.start do |http|
      http.request(req)
    end

    redirect_to organisation_view_path(params[:name])
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
