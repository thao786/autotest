class TestsController < ApplicationController
  before_action :set_test, except: [:index, :new, :create, :show]

  # GET /tests
  def index
    @per_page = 8
    if Test.count/@per_page.floor == Test.count/Float(@per_page)
      @num_page = Test.count/@per_page.floor
    else
      @num_page = Test.count/@per_page.floor + 1
    end
    @current_page = params[:page].to_i
    if params[:page] &&  @current_page <= @num_page && @current_page > 0
      @tests = Test.offset((@current_page - 1)*@per_page).limit(@per_page).order(created_at: :desc)
    else
      if params[:suite_id]
          @tests = Test.where(suite_id: params[:suite_id]).order(created_at: :desc)
      else
          @tests = Test.joins(:suite).where(suites: {user: current_user})
                   .order(created_at: :desc)
      end
    end
  end

  def paginate
    @per_page = 8
    if Test.count/@per_page.floor == Test.count/Float(@per_page)
      @num_page = Test.count/@per_page.floor
    else
      @num_page = Test.count/@per_page.floor + 1
    end
    @current_page = params[:page].to_i

  end

  # GET /tests/1
  def show
    @test = Test.find(params[:id])
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
    if @test.running
      render json: 'test is running', :status => 404
    else
      @test.destroy
      render json: true
    end
  end

  def add_new_param
    render partial: "add_test_params"
  end
  
  # generate an unique session ID
  def generateSession
    Step.where(test: @test).destroy_all
    sessionId = SecureRandom.base58(24)
    @test.update(session_id: sessionId)

    # set expiry date to 15 minutes from now
    @test.update(session_expired_at: Time.now + 15*60)

    render json: sessionId
  end

  # deactivate a test by setting expiry date to 24 hour ago
  def stopSession
    @test.update(session_expired_at: Time.now - 24*60*60)

    # consolidate drafts into steps
    helpers.parseDraft(@test.session_id)

    render json: 1
  end

  def addTestParams
    names = params[:param_names]
    values = params[:param_values]
    names.each_with_index { |value, index|
      if names[index].nil? || names[index].match?(/\s/) || names[index].empty?
        render plain: 'Test parameter label cannot contain blanks.', :status => 404 and return
      else
        if TestParam.where(test: @test, label: names[index]).count > 0
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

  def clear_steps
    Step.where(test: @test).destroy_all
    redirect_to @test.url
  end

  def generate_code
    file_name = @test.code_file_name current_user.language
    file_path = "#{ENV['HOME']}/#{ENV['dir']}/#{file_name}"
    if File.exist? file_path
      render plain: 'already generating'
    else
      file = File.new(file_path, "a")
      # insert boilerplate code
      file.puts "require 'selenium-webdriver'
driver = Selenium::WebDriver.for :chrome"

      first_step = Step.where(test: @test).first
      file.puts "driver.manage.window.resize_to(#{first_step.screenwidth}, #{first_step.screenheight})" if first_step.screenwidth

      if @test.suite.prep_tests.count > 0
        file.puts "# suite's pre-tests"
        @test.suite.prep_tests.each { |test|
          test.steps.each { |step|
            helpers.generate_step(file, step)
          }
        }
      end

      file.puts "# Test's steps"
      @test.steps.each { |step|
        helpers.generate_step(file, step)
      }

      @test.assertions.each { |assertion|
        helpers.generate_assertion(file, assertion)
      }
      file.close

      client = Aws::S3::Client.new(region: 'us-east-1')
      resource = Aws::S3::Resource.new(client: client)
      bucket = resource.bucket(ENV['bucket'])
      bucket.object(file_name).upload_file(file_path, acl:'public-read')

      File.delete file_path
      @test.update(code_generated_at: Time.now+1)
      render plain: "ok"
    end
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