class AssertionsController < ApplicationController
  before_action :set_assertion

  def newAssertionView
    @test = Test.find params[:test_id]
    render partial: "add_assertion"
  end

  def addAssertion
    test = Test.find params[:test_id]
    assertion = Assertion.create(webpage: params['webpage'],
               condition: params['condition'], test: test,
               assertion_type: params['assertionType'])
    if assertion.save
      redirect_to assertion.test.url
    else
      render json: false, :status => 404
    end
  end

  def removeAssertion
    @assertion.destroy
    render json: true
  end

  def disableAssertion
    if @assertion.active
      @assertion.update(active: false)
    else
      @assertion.update(active: true)
    end
    render json: true
  end

  private
    def set_assertion
      begin
        @assertion = Assertion.find(params[:assertion_id])
        if !helpers.own?(@assertion)
          render json: false, :status => 404
        end
      rescue
        @assertion = nil
      end
    end
end
