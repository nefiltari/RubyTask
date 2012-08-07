require 'uri'

class OrganisationsController < ApplicationController
  
  before_filter :login
  
  # GET /organisations
  def index
    @user = "Herp"

    require 'ostruct'    
    a1 = OpenStruct.new
    a1.sender = "Derpina"
    a1.receiver = "Herp"
    a1.action = "created a new Task"

    a2 = OpenStruct.new
    a2.sender = "Herp"
    a2.receiver = "Derpina"
    a2.action = "wrote a message"

    @last_activities = [a1, a2]

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create

    @params = params
    @o = nil
    unless Organisation.exist? :name => params[:name]
      o = Organisation.create name: params[:name]
      o.description = params[:description]
      o.add_member(@user, Ruta::Role.administrator)
      o.save!
      @o = o
      redirect_to "/organisations/#{URI.escape(o.name)}"
    end

    redirect_to "/organisations/new" unless @o
  end
  
  def show
    @org = Organisation.as name: params[:id]
    @members = @org.members
    @is_member = @org.exist_member? @user

    respond_to do |format|
      format.html # show.html.erb
    end
  end 

  def join
    @org = Organisation.as name: params[:id]
    @org.add_member(@user, Ruta::Role.administrator)
    @org.save!

    redirect_to '/organisations/'+URI.escape(params[:id])
  end

  def leave
    @org = Organisation.as name: params[:id]
    @org.delete_member @user
    @org.save!

    redirect_to '/organisations/'+URI.escape(params[:id])
  end

  def edit
    @org = Organisation.as name: params[:id]

    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  def edit_do
    @org = Organisation.as name: params[:name]
    @org.description = params[:description]
    @org.save!

    redirect_to "/organisations/#{URI.escape(@org.name)}"
  end

  def dialog
    @my_organisations = @user.organisations

    render partial: '/shared/dialog_organisations', layout: false
  end

  def dialog_add_member
    @friends = @user.friends
    require 'pp'
    pp @friends
    render partial: '/organisations/dialog_add_member', layout: false
  end

end
