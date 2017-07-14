require 'Util'

class ApplicationController < ActionController::Base
  before_action :authenticate_user!, except: [:documentation]

  protect_from_forgery with: :exception
  include Util

  def documentation
    render "layouts/documentation"
  end
end
