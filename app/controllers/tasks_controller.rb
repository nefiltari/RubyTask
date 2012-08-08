class TasksController < ApplicationController
  before_filter :login

  def index
    @tasks = @user.work_tasks
    @tasks.sort! { |x,y| x.priority <=> y.priority }.reverse!
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def show
    org = Organisation.as name: params[:organisation]
    proj = Project.as name: params[:project], organisation: org
    owner = Member.as name: params[:owner]
    target = (params[:target]) ? Member.as({name: params[:target]}) : nil;
    @task = Task.as name: params[:task], project: proj, owner: owner, target: target
    @is_member_project = proj.exist_member?(@user)
    @is_worker = @task.is_worker? @user
    @is_completed = @task.status == "complete"
    @priority = TasksHelper.priority_names(@task.priority)
  end

  def new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def dialog_add_member
    @task = nil
    if params[:task]
      org = Organisation.as name: params[:organisation]
      proj = Project.as name: params[:project], organisation: org
      owner = Member.as name: params[:owner]
      target = (params[:target]) ? Member.as({name: params[:target]}) : nil;
      @task = Task.as name: params[:task], project: proj, owner: owner, target: target
    end
    @org = Organisation.as name: params[:organisation]
    @proj = Project.as name: params[:project], organisation: @org
    @is_member = @org.exist_member? @user
    @members = (@is_member) ? @proj.members : []
    render partial: "dialog_add_member"
  end

  def edit
    org = Organisation.as name: params[:organisation]
    proj = Project.as name: params[:project], organisation: org
    owner = Member.as name: params[:owner]
    target = (params[:target]) ? Member.as({name: params[:target]}) : nil;
    pp target
    @task = Task.as name: params[:task], project: proj, owner: owner, target: target
  end

  def create
    org = Organisation.as name: params[:organisation]
    proj = Project.as name: params[:project], organisation: org
    if params[:all] == "yes"
      unless Task.exist? name: params[:name], project: proj, owner: @user
        t = Task.create name: params[:name], project: proj, owner: @user
        t.description = params[:description]
        t.priority = params[:priority].to_i
        t.workers = Set.new
        params[:workers].split(",").each do |w|
          t.workers.add(Member.as name: w)
        end
        t.save!
        redirect_to "/tasks/#{t.get_id}"
        return
      end
    else
      minimal_create = false
      workers = params[:workers].split(",")
      workers.each do |w|
        unless Task.exist? name: params[:name], project: proj, owner: @user, target: Member.as({name: w})
          t = Task.create name: params[:name], project: proj, owner: @user, target: Member.as({name: w})
          t.description = params[:description]
          t.priority = params[:priority].to_i
          t.workers = Set.new
          t.workers.add Member.as({name: w})
          minimal_create = true
          t.save!
        end
      end
      if minimal_create
        redirect_to project_view_path(params[:organisation],params[:project])
        return
      end
    end
    redirect_to "/tasks/#{params[:organisation]}/#{params[:project]}/new", alert: "This Task already exist!"
  end

  def complete
    org = Organisation.as name: params[:organisation]
    proj = Project.as name: params[:project], organisation: org
    owner = Member.as name: params[:owner]
    target = (params[:target]) ? Member.as({name: params[:target]}) : nil;
    task = Task.as name: params[:task], project: proj, owner: owner, target: target
    task.status = "complete"
    task.completed_at = DateTime.now
    task.save!
    redirect_to "/tasks/#{task.get_id}"
  end

  def update
    org = Organisation.as name: params[:organisation]
    proj = Project.as name: params[:project], organisation: org
    owner = Member.as name: params[:owner]
    target = (params[:target]) ? Member.as({name: params[:target]}) : nil;
    @task = Task.as name: params[:task], project: proj, owner: owner, target: target
    unless params[:target]
      @task.description = params[:description]
      @task.priority = params[:priority].to_i
      @task.workers = Set.new
      params[:workers].split(",").each do |w|
        @task.workers.add(Member.as name: w)
      end
      @task.save!
    else
      @task.destroy!
      workers = params[:workers].split(",")
      workers.each do |w|
        @task = Task.create name: params[:name], project: proj, owner: @user, target: Member.as({name: w})
        @task.description = params[:description]
        @task.priority = params[:priority].to_i
        @task.workers = Set.new
        @task.workers.add Member.as({name: w})
        @task.save!
      end
    end
    redirect_to "/tasks/#{@task.get_id}"
  end

  def destroy
    org = Organisation.as name: params[:organisation]
    proj = Project.as name: params[:project], organisation: org
    owner = Member.as name: params[:owner]
    target = (params[:target]) ? Member.as({name: params[:target]}) : nil;
    @task = Task.as name: params[:task], project: proj, owner: owner, target: target
    @task.destroy!
    redirect_to project_view_path(params[:organisation],params[:project])
  end
end
