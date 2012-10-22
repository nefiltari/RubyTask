class ProjectsController < ApplicationController

  before_filter :login

  # GET /projects/:organisation_id/:project_id
  def show
    @org = Organisation.as name: params[:organisation_id]
    @name = @org.name
    @project = Project.as name: params[:project_id], organisation: @org
    @projects = @org.projects
    @is_member = @project.exist_member? @user
    @is_member_org = @org.exist_member? @user
    @tasks = @org.tasks

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /projects/:organisation_id/new
  def new
    @org = Organisation.as name: params[:organisation_id]
    @org_name = @org.name
    @org_id = @org.get_id

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /projects/:organisation_id/:project_id/edit
  def edit
    @org = Organisation.as name: params[:organisation_id]
    @org_name = @org.name
    @org_id = @org.get_id
    @project = Project.as name: params[:project_id], organisation: @org
    @project_name = @project.name
    @project_id = @project.get_id
    @project_description = @project.description

    respond_to do |format|
      format.html # new.html.erb
    end    
  end

  def edit_do
    @id = params[:id]
    @org_id = @id.split("/")[0]
    @project_id = @id.split("/")[1]
    @description = params[:description]
    @org = Organisation.as name: @org_id
    @project = Project.as name: @project_id, organisation: @org
    @project.description = @description
    @project.save!

    redirect_to "/projects/#{@id}"
  end

  # POST /organisations/:organisation_id/create
  def create
    @org = Organisation.as name: params[:organisation_id]
    unless Project.exist? name: params[:title], organisation: @org
      project = Project.create name: params[:title], organisation: @org
      project.description = params[:description]
      project.add_member(@user, Ruta::Role.administrator)
      project.save!
      redirect_to "/projects/#{project.get_id}"
      return
    end
    redirect_to "/projects/#{params[:organisation_id]}/new", alert: "This Project already exist!"
  end

  def leave
    @org = Organisation.as name: params[:organisation_id]
    project = Project.as name: params[:project_id], organisation: @org
    project.delete_member @user
    project.save!

    redirect_to "/projects/#{params[:organisation_id]}/#{params[:project_id]}"
  end

  def join
    @org = Organisation.as name: params[:organisation_id]
    project = Project.create name: params[:project_id], organisation: @org
    project.add_member(@user, Ruta::Role.administrator)

    redirect_to "/projects/#{params[:organisation_id]}/#{params[:project_id]}"
  end

  def dialog_add_member
    @org = Organisation.as name: params[:organisation_id]
    @project = Project.create name: params[:project_id], organisation: @org
    @member = (@org.member.map{|m| m.member.name} - @project.member.map{|m| m.member.name}).map{|m| Member.as name: m}

    render partial: '/projects/dialog_add_member', layout: false
  end

  def add_member
    @org = Organisation.as name: params[:organisation_id]
    @project = Project.create name: params[:project_id], organisation: @org
    @member_id = params[:member_id]
    @member = Member.as name: @member_id

    @project.add_member @member, Ruta::Role.administrator

    render :nothing => true
  end
end
