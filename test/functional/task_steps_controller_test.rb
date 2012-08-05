require 'test_helper'

class TaskStepsControllerTest < ActionController::TestCase
  setup do
    @task_step = task_steps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:task_steps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create task_step" do
    assert_difference('TaskStep.count') do
      post :create, task_step: {  }
    end

    assert_redirected_to task_step_path(assigns(:task_step))
  end

  test "should show task_step" do
    get :show, id: @task_step
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @task_step
    assert_response :success
  end

  test "should update task_step" do
    put :update, id: @task_step, task_step: {  }
    assert_redirected_to task_step_path(assigns(:task_step))
  end

  test "should destroy task_step" do
    assert_difference('TaskStep.count', -1) do
      delete :destroy, id: @task_step
    end

    assert_redirected_to task_steps_path
  end
end
