class DashboardController < ApplicationController
  def save_setting
    current_user.update(language: params[:language])
    flash[:notice] = "Your settings have been saved."
    redirect_to '/suites'
  end
end
