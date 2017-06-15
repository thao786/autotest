module ResultsHelper
  def resultUrl(result)
    "/results/#{result.runID}"
  end
end
