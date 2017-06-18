class ResultsController < ApplicationController
  # GET /results
  def index
    @results = Result.all
  end

  # GET /results/runID
  def show
    @runId = params[:id]
    @results = Result.where(runID: @runId)

    if @results.count > 0
      @test = @results.first.test
      @results = @results.select {|result| result.assertion.assertion_type != 'report'}
      @assertions = Assertion.where(test: @test)
      # s3 = Aws::S3::Client.new(region:'us-east-1')
      # resp = s3.list_objects(bucket: ENV['bucket'], prefix: "#{params[:id]}-")
      # @pics = resp.contents
    else
      render plain: 'not found'
    end
  end
end
