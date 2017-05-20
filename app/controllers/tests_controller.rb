class TestsController < ApplicationController
  before_action :set_test, except: [:index, :new, :create, :show]

  # GET /tests
  def index
    @tests = Test.joins(:suite).where(suites: {user: current_user})
  end

  # GET /tests/1
  def show
    @test = Test.find(params[:id])
    @suite = @test.suite
  end

  # GET /tests/new
  def new
    @test = Test.new
    @suite = Suite.find(params[:suite_id]) if params[:suite_id].present?
    render template: "tests/new", :layout => false
  end

  # GET /tests/1/edit
  def edit
  end

  # POST /tests
  def create
    title = makeNameId params[:title]
    name = title
    while Test.find_by(name: name)
      random = rand 10000
      name = "#{title}_#{random}"
    end

    @test = Test.new(title: title, name: name, description: params[:description],
                     suite_id: params[:suite])

    if @test.save
      redirect_to @test.url, notice: 'Test was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /tests/1
  def update
    @test = Test.find_by(id: params[:id], suite: @suite)
    test_params[:suite_id] = @suite.id

    if @test.update(test_params)
      redirect_to @test.url, notice: 'Test was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /tests/1
  def destroy
    @test.destroy
    render json: true
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