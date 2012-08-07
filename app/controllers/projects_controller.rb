class ProjectsController < ApplicationController

  # GET /projects/:organisation_id/:project_id
  def show
    @org = Organisation.as name: params[:organisation_id]
    @name = @org.name
    @project = Project.as name: params[:project_id], organisation: @org

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

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
  end

  # POST /organisations/:organisation_id/create
  def create
    @org = Organisation.as name: params[:organisation_id]
    project = Project.create name: params[:title], organisation: @org
    project.description = params[:description]
    project.add_member(@user, Ruta::Role.administrator)
    project.save!

    redirect_to "/projects/#{params[:organisation_id]}/#{project.get_id}"
  end

  
end
