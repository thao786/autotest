class TestsController < ApplicationController
  before_action :set_test, except: [:index, :new, :create, :show]

  # GET /tests
  def index
    @tests = Test.joins(:suite).where(suites: {user: current_user})
                 .order(created_at: :desc)
  end

  # GET /tests/1
  def show
    @test = Test.find(params[:id])
    @result = nil
    if Result.where(test: @test).count > 0
      @result = Result.where(test: @test).order("id DESC").first
    end
  end

  # GET /tests/new
  def new
    @suite = Suite.find(params[:suite_id]) if params[:suite_id].present?
    render template: "tests/new", :layout => false
  end

  # GET /tests/1/edit
  def edit
    @suite = @test.suite
    render template: "tests/new", :layout => false
  end

  # POST /tests
  def create
    title = makeNameId params[:title]
    name = title
    while Test.find_by(name: name)
      random = rand 10000
      name = "#{title}_#{random}"
    end

    @test = Test.new(title: params[:title], name: name, description: params[:description],
                     suite_id: params[:suite])

    if @test.save
      redirect_to @test.url, notice: 'Test was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /tests/1
  def update
    @test.title = params[:title]
    @test.description = params[:description]
    @test.suite = Suite.find params[:suite]

    if @test.save!
      redirect_to @test.url, notice: 'Test was successfully updated.'
    else
      render plain: 'failed', :status => 404
    end
  end

  # DELETE /tests/1
  def destroy
    @test.destroy
    render json: true
  end

  def add_new_param
    render partial: "add_test_params"
  end
  
  # generate an unique session ID
  def generateSession
    Step.where(test: @test).destroy_all
    sessionId = SecureRandom.base58(24)
    @test.update(session_id: sessionId)

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
    names.each_with_index { |value, index|
      if names[index].nil? || names[index].match?(/\s/) || names[index].empty?
        render plain: 'Blank not allowed', :status => 404 and return
      else
        if TestParam.where(test: @test, label: names[index])
          render plain: 'This test already has a parameter with this label', :status => 404 and return
        else
          TestParam.create(test: @test, label: names[index], val: values[index])
        end
      end
    }
    render partial: 'tests/test_params', :status => 200
  end

  def removeTestParams
    TestParam.where(test: @test, label: params[:key]).destroy_all
    render json: @test.id
  end

  def runTest
    Result.where(test: @test).destroy_all # only 1 test can be ran at a time
    @test.update(running: true)
    folder = "#{ENV['HOME']}/#{ENV['picDir']}/#{@test.id}"
    FileUtils.rm_r folder if Dir.exist?(folder)
    Dir.mkdir folder

    if Rails.env.development?
      first_step = Step.where(test: @test).first
      driver = Selenium::WebDriver.for :chrome
      driver.manage.window.resize_to(first_step.screenwidth, first_step.screenheight)
      helpers.runSteps(driver, @test, @test.id)
      driver.quit
    else # call the independent EC2 servers
      data = {:password => ENV['RDS_PASSWORD'], :test_id => @test.id}
      json = JSON.generate data
      public_key = OpenSSL::PKey::RSA.new(File.read("#{ENV['HOME']}/public.pem"))
      encrypted_string = Base64.encode64(public_key.public_encrypt(json))
      url = "http://34.213.223.51/api/runTest?data=#{encrypted_string}"
    end

    @test.update(running: false)
    render json: @test.id
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