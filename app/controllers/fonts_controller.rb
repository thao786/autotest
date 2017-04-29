class FontsController < ApplicationController
  def index
    path = ''
    if Rails.env.development?
      path = "/Users/thao786"
    end

    send_file "#{path}/autotest/vendor/assets/fonts/#{params[:font]}.#{params[:format]}"
  end
end
