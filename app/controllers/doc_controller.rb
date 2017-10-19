class DocController < ActionController::Base
  layout 'link_wrapper'

  def intro
    render template: 'doc/intro'
  end

  def doc
    render template: 'doc/documentation'
  end
end
