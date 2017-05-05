class StepController < ApplicationController
  before_action :set_step, :set_test
  before_action :authorize?

  def delete_step
    @step.destroy
    render json: true
  end

  def change_wait
    @step.update(wait: params[:wait])
    if @step.valid?
      render json: true
    else
      render json: @step.errors.full_messages, :status => 404
    end
  end

  def change_webpage
    if params[:webpage].empty?
      render json: false, :status => 404
    else
      @step.update(webpage: params[:webpage])
      render json: true
    end
  end

  def change_selector
    form = Rack::Utils.parse_nested_query(params[:form])
    if form['selectorType'].present?
      @step.update(selector: {selectorType: form['selectorType'], eq: form['eq'],
                              selector: form['selector']}.to_json)
    elsif form['selector'] == 'coordination'
      @step.update(selector:
           {selectorType: 'coordination', x: @step.config[:x], y: @step.config[:y]}.to_json)
    else
      @step.update(selector: @step.config[:selectors][form['selector'].to_i].to_json)
    end

    render partial: "step/show_step", :locals => {:step => @step}
  end

  def edit_view
    render partial: "edit_#{@step.action_type}"
  end

  def save_pageload
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
  end

  def save_keypress
    form = Rack::Utils.parse_nested_query(params[:form])
    if form['typed'].present?
      @step.update(typed: form['typed'])
      render partial: "step/show_step", :locals => {:step => @step}
    else
      render json: false
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
    form = Rack::Utils.parse_nested_query(params[:form])

    if @step
      # make room: increase all order by 1
      steps = Step.where("steps.order > ?", @step.order).where(test: @test)
      steps.each { |step|
        step.update(order: step.order + 1)
      }
      new_step = Step.create(test: @test, order: @step.order + 1,
                             action_type: form['action_type'], wait: form['wait'])
    else
      new_step = Step.create(test: @test, order: @test.steps.maximum('order') + 1,
                             action_type: form['action_type'], wait: form['wait'])
    end

    render partial: "step/show_step", :locals => {:step => new_step}
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
    if  !helpers.own?(@step)
      render json: false
    end
  end
end
