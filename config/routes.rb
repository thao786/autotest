Rails.application.routes.draw do
  get '/doc', to: 'application#documentation'

  get 'fonts/*font', to: 'fonts#index'

  get 'step/delete_step', to: 'step#delete_step'
  match 'step/save_click', to: 'step#save_click', via: [:post]
  get 'step/edit_view', to: 'step#edit_view'
  match 'step/save_pageload', to: 'step#save_pageload', via: [:post]
  match 'step/remove_header_param', to: 'step#remove_header_param', via: [:post]
  match 'step/remove_pageload_param', to: 'step#remove_pageload_param', via: [:post]
  get 'step/add_step_view', to: 'step#add_step_view'
  match 'step/save_new_step', to: 'step#save_new_step', via: [:post]
  match 'step/save_config', to: 'step#save_config', via: [:post]
  match 'step/save_scroll', to: 'step#save_scroll', via: [:post]
  match 'step/save_keypress', to: 'step#save_keypress', via: [:post]
  match 'step/removeExtract', to: 'step#removeExtract', via: [:post]
  get 'step/configModal', to: 'step#configModal'
  match 'step/saveConfig', to: 'step#saveConfig', via: [:post]

  match 'tests/addTestParams', to: 'tests#addTestParams', via: [:post]
  match 'tests/removeTestParams', to: 'tests#removeTestParams', via: [:post]
  get 'test/:name/:id', to: 'tests#show'
  get 'tests/add_new_param', to: 'tests#add_new_param'
  get 'tests/generateSession', to: 'tests#generateSession'
  get 'tests/stopSession', to: 'tests#stopSession'
  get 'tests/runTest', to: 'tests#runTest'

  get 'assertions/newAssertionView', to: 'assertions#newAssertionView'
  match 'assertions/addAssertion', to: 'assertions#addAssertion', via: [:post]
  match 'assertions/removeAssertion', to: 'assertions#removeAssertion', via: [:post]
  match 'assertions/disableAssertion', to: 'assertions#disableAssertion', via: [:post]

  match 'api/check', to: 'api#check', via: [:get, :post]
  match 'api/saveEvent', to: 'api#saveEvent', via: [:post]

  match 'suites/saveConfig', to: 'suites#saveConfig', via: [:post]

  root to: 'api#intro'

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  resources :users, :plans, :suites, :tests, :results
end
