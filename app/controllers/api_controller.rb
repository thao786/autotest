class ApiController < ActionController::Base
  def check
    if Test.find_by(session_id: params[:session_id])
      render json: true
    else
      render json: false, :status => 404
    end
  end

  # save this event to draft and update test's cache response
  def saveEvent
    if params[:action_type] == 'pageload' and params[:webpage] =~ %r|http(.*)google(.*)/_/chrome/newtab|
      render json: {}
    elsif (Rails.env.development? and params[:webpage] =~ %r|localhost:3000|) or
        (Rails.env.test? and params[:webpage] =~ %r|https://test.uichecks.com|) or
        (Rails.env.production? and params[:webpage] =~ %r|https://uichecks.com|)
      render json: {}
    else
      test = Test.find_by(session_id: params[:session_id])

      if test and test.session_expired_at > DateTime.now
        test.update(session_expired_at: (Time.now + 15*60))
        hash = params.to_unsafe_h
        params[:draft] = hash

        draft = Draft.create(params.require(:draft).permit(:webpage, :stamp, :apk, :activity, :action_type, :session_id, :typed, :screenwidth, :screenheight, :scrollTop, :scrollLeft, :x, :y, :tabId, :windowId))

        draft.update(selector: {selector: params[:selector], eq: params[:eq].to_i, selectorType: params[:selectorType], childrenCount: params[:childrenCount].to_i})
      end

      render json: {}
    end
  end
end
