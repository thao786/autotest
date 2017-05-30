class DashboardController < ApplicationController

  def billing
  end

  def index
    @tests = Test.joins(:suite).where(suites: { user: current_user})
  end

  def intro
    render file: 'layouts/intro', :layout => false
  end
end
