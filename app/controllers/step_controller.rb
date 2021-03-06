class StepController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_step, :set_test
  before_action :authorize?

  def delete_step
    @step.destroy
    render json: true
  end

  def save_click
    form = Rack::Utils.parse_nested_query(params[:form])
    if form['eq'].present?
      unless form['eq'].strip =~ /[0-9]+/
        render plain: 'Index has to be an integer', :status => 404
        return
      end
    end

    if form['selectorType'].present? # custom selector form
      if form['selector'] == 'coordination'
        @step.update(selector: {selectorType: 'coordination',
                                x: form['x'] ||= @step.config[:x],
                                y: form['y'] ||= @step.config[:y]})
      elsif form['selector'].blank?
          render plain: 'CSS Selector Missing', :status => 404
          return
      else
        @step.update(selector: {selectorType: form['selectorType'],
                                eq: form['eq'] ||= 0, selector: form['selector']})
      end
    else # one of the default selectors
      @step.update(selector: @step.config[:selectors][form['selector'].to_i])
    end

    @step.update(wait: form['wait']) if form['wait'].present?
    render json: true
  end

  def edit_view
    render partial: "edit_#{@step.action_type}"
  end

  def save_pageload
    form = Rack::Utils.parse_nested_query(params[:form])
    if form['webpage'] =~ URI::regexp
      @step.update(webpage: form['webpage'])
      @step.update(wait: form['wait']) if form['wait'].present?
    else
      render plain: 'Incorrect Format Or Blank Webpage', :status => 404
    end
    @step.update(wait: form['wait']) if form['wait'].present?
  end

  def save_config
    form = Rack::Utils.parse_nested_query(params[:form])
    unless form['extract_names'].nil?
      form['extract_names'].each do |en|
        if en.match?(/\s/) || en.empty?
          render plain: 'Blank not allowed', :status => 404
        end
      end
    end
  end

  def save_pageload_curl
    form = Rack::Utils.parse_nested_query(params[:form])
    @step.update(webpage: form['webpage']) if form['webpage'].present?
    @step.update(wait: form['wait']) if form['wait'].present?

    hash = @step.config ||= {}
    hash[:method] = form['method'] if form['method'].present?

    if form['header_names'].present?
      hash[:headers] = @step.config[:headers] ||= {}
      names = form['header_names']
      values = form['header_values']
      names.each_with_index { |value, index|
        if names[index].present?
          hash[:headers][value] = values[index]
        end
      }
    end

    if form['param_names'].present?
      hash[:params] = @step.config[:params] ||= {}
      names = form['param_names']
      values = form['param_values']
      names.each_with_index { |value, index|
        if names[index].present?
          hash[:params][value] = values[index]
        end
      }
    end

    @step.update(config: hash)
    @step.update(wait: form['wait']) if form['wait'].present?
  end

  def save_keypress
    form = Rack::Utils.parse_nested_query(params[:form])
    if form['typed'].present?
      @step.update(typed: form['typed'])
      render partial: "step/show", :locals => {:step => @step}
    else
      render json: false
    end
    @step.update(wait: form['wait']) if form['wait'].present?
  end

  def save_scroll
    form = Rack::Utils.parse_nested_query(params[:form])
    if form['scrollTop'] =~ /[0-9]+/ && form['scrollLeft'] =~ /[0-9]+/
      @step.update(scrollTop: form['scrollTop'])
      @step.update(scrollLeft: form['scrollLeft'])
      @step.update(wait: form['wait']) if form['wait'].present?
    else
      render plain: 'Parameters can only contain numbers and not be blank.', :status => 404
    end
  end

  def remove_header_param
    hash = @step.config ||= {}
    hash[:headers].delete params[:key]
    @step.update(config: hash)
  end

  def remove_pageload_param
    hash = @step.config ||= {}
    hash[:params].delete params[:key]
    @step.update(config: hash)
  end

  def add_step_view
    render partial: "add_step"
  end

  def save_new_step
    if @step
      # make room: increase all order by 1
      steps = Step.where("steps.order > ?", @step.order).where(test: @test)
      steps.each { |step|
        step.update(order: step.order + 1)
      }
      Step.create(test: @test, order: @step.order + 1,
                  action_type: params['action_type'], wait: params['wait'])
    else
      order = @test.steps.maximum('order')
      order ||= 0
      Step.create(test: @test, order: order + 1,
                  action_type: params['action_type'], wait: params['wait'])
    end

    redirect_back fallback_location: @test
  end

  def removeExtract
    @extract = Extract.find params[:extract_id]
    if helpers.own? @extract
      @extract.destroy
      render json: true
    end

    render json: false
  end

  def saveConfig
    #validate input
    form = Rack::Utils.parse_nested_query(params[:form])
    unless form['extract_names'].nil?
      form['extract_names'].each do |en|
        if en.match?(/\s/) || en.empty?
          render plain: 'Blank not allowed', :status => 404 and return
        end
      end
    end

    # save pre-steps
    PrepTest.destroy_all(step: @step)
    form['pre_run_tests'].each { |test_id|
      test = Test.find test_id
      if test.prep_tests.count == 0
        order = PrepTest.where(suite: @suite, test: test).maximum(:order)
        order ||= 0
        PrepTest.create(step: @step, test: test, order: order + 1)
      end
    } if params['pre_run_tests'].present?

    # save extracts
    form['extract_names'].each_with_index { |name, index|
      Extract.create(step: @step, title: name, command: form['extract_js'][index])
    } if form['extract_names'].present?

    redirect_to "/test/#{@step.test.name}/#{@step.test.id}"
  end

  def configModal
    render partial: 'step/config'
  end

  def set_test
    begin
      id ||= params[:test_id]
      @test = Test.find(id)
    rescue
      @test = nil
    end
  end

  def set_step
    begin
      id ||= params[:step_id]
      @step = Step.find(id)
    rescue
      @step = nil
    end
  end

  def authorize?
    if !helpers.own?(@step)
      render json: false
    end
  end
end
