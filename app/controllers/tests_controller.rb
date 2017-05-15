class TestsController < ApplicationController
  before_action :set_test, except: [:index, :new, :create, :show]

  # GET /tests
  # GET /tests.json
  def index
    @tests = Test.joins(:suite).where(suites: {user: current_user})
  end

  # GET /tests/1
  # GET /tests/1.json
  def show
    @test = Test.find(params[:id])
    @suite = @test.suite
  end

  # GET /tests/new
  def new
    @test = Test.new
    @suite = Suite.find(params[:suite_id]) if params[:suite_id].present?
    render template: "tests/new"
  end

  # GET /tests/1/edit
  def edit
  end

  # POST /tests
  # POST /tests.json
  def create
    title = makeNameId test_params[:title]
    name = title
    while Test.find_by(name: name, suite: @suite)
      random = rand 10000
      name = "#{title}_#{random}"
    end
    test_params[:name] = name
    test_params[:suite_id] = @suite.id

    @test = Test.new(test_params)

    respond_to do |format|
      if @test.save
        format.html { redirect_to "/suites/#{@suite.name}/tests/#{@test.name}", notice: 'Test was successfully created.' }
        format.json { render :show, status: :created, location: @test }
      else
        format.html { render :new }
        format.json { render json: @test.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tests/1
  # PATCH/PUT /tests/1.json
  def update
    @test = Test.find_by(id: params[:id], suite: @suite)
    test_params[:suite_id] = @suite.id

    respond_to do |format|
      if @test.update(test_params)
        format.html { redirect_to "/suites/#{@suite.name}/tests/#{@test.name}", notice: 'Test was successfully updated.' }
        format.json { render :show, status: :ok, location: @test }
      else
        format.html { render :edit }
        format.json { render json: @test.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tests/1
  # DELETE /tests/1.json
  def destroy
    @test.destroy
    respond_to do |format|
      format.html { redirect_to tests_url, notice: 'Test was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # generate an unique session ID
  def generateSession
    @test.steps.destroy_all
    sessionId = SecureRandom.base58(24)
    @test.session_id=sessionId

    while !@test.save
      sessionId = SecureRandom.base58(24)
      @test.session_id=sessionId
      @test.save
    end

    # set expiry date to 15 minutes from now
    @test.session_expired_at=Time.now + 15*60
    @test.save

    render json: sessionId
  end

  # deactivate a test by setting expiry date to 24 hour ago
  def stopSession
    @test.session_expired_at=Time.now - 24*60*60
    @test.save

    # consolidate drafts into steps
    helpers.parseDraft(@test.session_id)

    render json: 1
  end

  def addTestParams
    names = params[:param_names]
    values = params[:param_values]
    hash = @test.params ||= {}
    names.each_with_index { |value, index|
      if names[index].present?
        hash[value] = values[index]
      end
    }
    @test.update(params: hash)
    render partial: 'tests/test_params', :status => 200
  end

  def removeTestParams
    hash = @test.params
    hash.delete params[:key]
    @test.update(params: hash)
    render json: 1
  end

  def runTest

  end

  def newAssertionView
    render partial: "add_assertion"
  end

  def addAssertion
    form = Rack::Utils.parse_nested_query(params[:form])
    assertion = Assertion.create(webpage: form['webpage'], condition: form['condition'], test: @test)
    if assertion.save
      render partial: "tests/show_assertion", :locals => {:assertion => assertion}
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
end