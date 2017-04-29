class DashboardController < ApplicationController
  def billing
  end

  def preferences
  end

  def index
    @tests = Test.joins(:suite).where(suites: { user: current_user})
  end
end
