class SuitesController < ApplicationController
  before_action :set_suite, except: [:index, :new, :create, :show]

  DISPLAY_PER_PAGE = 50

  # GET /suites
  def index
    page = params[:page] ? params[:page].to_i : 0
    offset = page * DISPLAY_PER_PAGE
    @suites = Suite.where(user: current_user).order(created_at: :desc).offset(offset)
  end

  # GET /suites/1
  def show
  end

  # GET /suites/new
  def new
    @suite = Suite.new
    render template: "suites/new", :layout => false
  end

  # GET /suites/1/edit
  def edit
  end

  def saveConfig
    render json: 5
  end

  # POST /suites
  def create
    suite_params[:user_id] = current_user.id

    # make a unique name for this user's suite
    suite_params[:name] = makeNameId suite_params[:title]
    title = makeNameId suite_params[:title]
    name = title
    while Suite.find_by(title: suite_params[:title], user: current_user)
      random = rand 10000
      name = "#{title}_#{random}"
    end
    suite_params[:name] = name

    @suite = Suite.new(suite_params)

    if @suite.save
      redirect_to controller: 'suites', action: 'show', id: @suite.name, notice: 'Suite was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /suites/1
  def update
    @suite = Suite.find_by(id: params[:id], user: current_user)
    suite_params[:user_id] = current_user.id

    if @suite.update(suite_params)
      redirect_to controller: 'suites', action: 'show', id: @suite.name, notice: 'Suite was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /suites/1
  def destroy
    @suite.destroy
    render json: true
  end

  private
    # Url uses name in place of id, for user's readability
    def set_suite
      @suite = Suite.find_by(name: params[:id], user: current_user)
    end

    def suite_params
      params.require(:suite).permit!
    end
end
