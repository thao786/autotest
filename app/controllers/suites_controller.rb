class SuitesController < ApplicationController
  before_action :set_suite, only: [:show, :edit, :update, :destroy]

  DISPLAY_PER_PAGE = 50

  # GET /suites
  # GET /suites.json
  def index
    page = params[:page] ? params[:page].to_i : 0
    offset = page * DISPLAY_PER_PAGE
    @suites = Suite.where(user: current_user).order(created_at: :desc).offset(offset)
  end

  # GET /suites/1
  # GET /suites/1.json
  def show
  end

  # GET /suites/new
  def new
    @suite = Suite.new
  end

  # GET /suites/1/edit
  def edit
  end

  # POST /suites
  # POST /suites.json
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

    respond_to do |format|
      if @suite.save
        format.html { redirect_to controller: 'suites', action: 'show', id: @suite.name, notice: 'Suite was successfully created.' }
        format.json { render :show, status: :created, location: @suite }
      else
        format.html { render :new }
        format.json { render json: @suite.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /suites/1
  # PATCH/PUT /suites/1.json
  def update
    @suite = Suite.find_by(id: params[:id], user: current_user)
    suite_params[:user_id] = current_user.id

    respond_to do |format|
      if @suite.update(suite_params)
        format.html { redirect_to controller: 'suites', action: 'show', id: @suite.name, notice: 'Suite was successfully updated.' }
        format.json { render :show, status: :ok, location: @suite }
      else
        format.html { render :edit }
        format.json { render json: @suite.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /suites/1
  # DELETE /suites/1.json
  def destroy
    @suite.destroy
    respond_to do |format|
      format.html { redirect_to suites_url, notice: 'Suite was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    # Url uses name in place of id, for user's readability
    def set_suite
      @suite = Suite.find_by(name: params[:id], user: current_user)
    end

    def suite_params
      params.require(:suite).permit!
    end
end
