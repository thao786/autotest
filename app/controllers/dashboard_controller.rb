class DashboardController < ApplicationController

  def billing
  end

  def index
    @tests = Test.joins(:suite).where(suites: {users: current_user})
  end
end
