class ResultsController < ApplicationController
  # GET /results
  def index
    @results = Result.all
  end

  # GET /results/runID
  def show
    @results = Result.where(runID: params[:runID])
  end
end
