class ResultsController < ApplicationController
  # GET /results
  def index
    @results = Result.all
  end

  # GET /results/runID
  def show
    @results = Result.where(runID: params[:id])
    if @results.count > 0
      @test = @results.first.test
    else
      render plain: 'not found'
    end
  end
end
