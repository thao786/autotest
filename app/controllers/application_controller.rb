require 'Util'

class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  protect_from_forgery with: :exception
  include Util

  protected
  def after_sign_in_path_for(resource)
    '/suites'
  end
end
