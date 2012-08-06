class SessionsController < ApplicationController

  def new
    respond_to do |format|
      format.html
    end
  end

  def create

  end

  def destroy
    @session = Session.find(params[:id])
    @session.destroy

    respond_to do |format|
      format.html { redirect_to sessions_url }
      format.json { head :no_content }
    end
  end
end
