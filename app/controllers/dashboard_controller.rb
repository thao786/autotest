class DashboardController < ApplicationController

  def billing
  end

  def index
    @tests = Test.joins(:suite).where(suites: {users: current_user})
  end

  def intro
    render file: 'layouts/intro', :layout => false
  end
end
