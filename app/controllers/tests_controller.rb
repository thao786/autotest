class TestsController < ApplicationController
  before_action :set_test, except: [:index, :new, :create, :show]

  # GET /tests
  def index
    if params[:suite_id]     
        @tests = Test.where(suite_id: params[:suite_id]).order(created_at: :desc)
    else             
        @tests = Test.joins(:suite).where(suites: {user: current_user})
                 .order(created_at: :desc)
    end
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

  def generate_code
    hash = Digest::MD5.hexdigest "#{ENV['RDS_HOSTNAME']}-#{data}"
    languages = {'ruby'=>'rb', 'python'=>'py', 'java'=>'java', 'javascript'=>js}
    file_name = "#{hash}.#{languages[current_user.language]}"
    file_path = "#{ENV['picDir']}/#{file_name}"
    if File.exist? file_path
      render plain: 'already generating', :status => 404
    else
      file = File.new(file_path, "a")
      test.steps.each { |step|
        helpers.generate_step(file, step)
      }
      file.close

      client = Aws::S3::Client.new(region: 'us-east-1')
      resource = Aws::S3::Resource.new(client: client)
      bucket = resource.bucket(ENV['bucket'])
      bucket.object(file_name).upload_file(file_path, acl:'public-read')

      File.delete file_path
      render plain: "https://s3.amazonaws.com/#{ENV['bucket']}/#{file_name}"
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