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
    if params[:type] == "project"

    require 'net/http'
    uri = URI('https://graph.facebook.com/#{params[:id]}/feed')
    res = Net::HTTP.post_form(uri, 'access_token' => session[:access_token].to_s, 'message' => "You are invited to the following #{params[:type].capitalize}.")

end
