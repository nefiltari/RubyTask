class TasksController < ApplicationController
  before_filter :login

  # GET /tasks
  # GET /tasks.json
  def index
    @tasks = Task.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tasks }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
    @task = Task.as name: params[:id]
  end

  # GET /tasks/new
  # GET /tasks/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def dialog_add_member
    @org = Organisation.as name: params[:organisation]
    @members = @org.members
    render partial: "dialog_add_member"
  end

  # GET /tasks/1/edit
  def edit
    @task = Task.find(params[:id])
  end

  def create
    org = Organisation.as name: params[:organisation]
    proj = Project.as name: params[:project], organisation: org
    if param[:all] == "yes"
      t = Task.create name: params[:name], project: proj, owner: @user
      t.description = params[:description]
      t.priority = params[:priority].to_i
      t.workers = Set.new
      params[:workers].split(",").each do |w|
        t.workers.add(Member.as name: w)
      end
      t.save!
    else      
      workers = params[:workers].split(",")
      workers.each do |w|
        t = Task.create name: params[:name], project: proj, owner: @user, target: Member.as({name: w})
        t.description = params[:description]
        t.priority = params[:priority].to_i
        t.workers = Set.new
        t.workers.add Member.as({name: w})
        t.save!
      end
    end
    redirect_to project_view_path(params[:project])
  end

  # PUT /tasks/1
  # PUT /tasks/1.json
  def update
    
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task = Task.find(params[:id])
    @task.destroy

    respond_to do |format|
      format.html { redirect_to tasks_url }
      format.json { head :no_content }
    end
  end
end
