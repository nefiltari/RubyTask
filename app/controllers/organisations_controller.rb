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

  
end
