class FontsController < ApplicationController
  def index
    send_file "#{ENV['HOME']}/autotest/vendor/assets/fonts/#{params[:font]}.#{params[:format]}"
  end
end
