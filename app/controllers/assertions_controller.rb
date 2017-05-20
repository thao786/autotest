class AssertionsController < ApplicationController
  before_action :set_test

  def newAssertionView
    render partial: "add_assertion"
  end

  def addAssertion
    assertion = Assertion.create(webpage: params['webpage'],
               condition: params['condition'], test: @test, assertion_type: params['assertionType'])
    if assertion.save
      redirect_to "/test/#{@test.name}/#{@test.id}"
    else
      render json: false, :status => 404
    end
  end

  def removeAssertion
    Assertion.find(params[:assertion_id]).destroy
    render json: true
  end

  def disableAssertion
    assertion = Assertion.find(params[:assertion_id])
    if assertion.active
      assertion.update(active: false)
    else
      assertion.update(active: true)
    end
    render json: true
  end

  private
    def set_test
      begin
        @test = Test.find(params[:test_id])
        if !helpers.own?(@test)
          render json: false, :status => 404
        end
      rescue
        @test = nil
      end
    end

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
