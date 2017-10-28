class DashboardController < ApplicationController
  def save_setting
    flash[:notice] = "Your settings have been saved."
    redirect_to '/suites'
  end
end
