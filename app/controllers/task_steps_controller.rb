class TaskStepsController < ApplicationController
  # GET /task_steps
  # GET /task_steps.json
  def index
    @task_steps = TaskStep.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @task_steps }
    end
  end

  # GET /task_steps/1
  # GET /task_steps/1.json
  def show
    @task_step = TaskStep.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @task_step }
    end
  end

  # GET /task_steps/new
  # GET /task_steps/new.json
  def new
    @task_step = TaskStep.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @task_step }
    end
  end

  # GET /task_steps/1/edit
  def edit
    @task_step = TaskStep.find(params[:id])
  end

  # POST /task_steps
  # POST /task_steps.json
  def create
    @task_step = TaskStep.new(params[:task_step])

    respond_to do |format|
      if @task_step.save
        format.html { redirect_to @task_step, notice: 'Task step was successfully created.' }
        format.json { render json: @task_step, status: :created, location: @task_step }
      else
        format.html { render action: "new" }
        format.json { render json: @task_step.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /task_steps/1
  # PUT /task_steps/1.json
  def update
    @task_step = TaskStep.find(params[:id])

    respond_to do |format|
      if @task_step.update_attributes(params[:task_step])
        format.html { redirect_to @task_step, notice: 'Task step was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @task_step.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /task_steps/1
  # DELETE /task_steps/1.json
  def destroy
    @task_step = TaskStep.find(params[:id])
    @task_step.destroy

    respond_to do |format|
      format.html { redirect_to task_steps_url }
      format.json { head :no_content }
    end
  end
end
