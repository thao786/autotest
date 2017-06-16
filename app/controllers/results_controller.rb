class ResultsController < ApplicationController
  # GET /results
  def index
    @results = Result.all
  end

  # GET /results/runID
  def show
    @rundId = params[:id]
    @results = Result.where(runID: @rundId)

    if @results.count > 0
      @test = @results.first.test
      # s3 = Aws::S3::Client.new(region:'us-east-1')
      # resp = s3.list_objects(bucket: ENV['bucket'], prefix: "#{params[:id]}-")
      # @pics = resp.contents
    else
      render plain: 'not found'
    end
  end
end
