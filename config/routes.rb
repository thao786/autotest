Rails.application.routes.draw do
  get 'dashboard/index'
  get 'dashboard/billing'
  get 'dashboard/preferences'

  get 'fonts/*font', to: 'fonts#index'

  get 'step/delete_step', to: 'step#delete_step'
  get 'step/change_wait', to: 'step#change_wait'
  get 'step/change_webpage', to: 'step#change_webpage'
  match 'step/change_selector', to: 'step#change_selector', via: [:post]
  get 'step/edit_view', to: 'step#edit_view'
  match 'step/save_pageload', to: 'step#save_pageload', via: [:post]
  match 'step/remove_header_param', to: 'step#remove_header_param', via: [:post]
  match 'step/remove_pageload_param', to: 'step#remove_pageload_param', via: [:post]
  get 'step/add_step_view', to: 'step#add_step_view'
  match 'step/save_new_step', to: 'step#save_new_step', via: [:post]

  match 'tests/addTestParams', to: 'tests#addTestParams', via: [:post]
  match 'tests/removeTestParams', to: 'tests#removeTestParams', via: [:post]
  get 'test/:name/:id', to: 'tests#show'
  get 'tests/generateSession', to: 'tests#generateSession'
  get 'tests/stopSession', to: 'tests#stopSession'
  get 'tests/runTest', to: 'tests#runTest'
  get 'tests/newAssertionView', to: 'tests#newAssertionView'

  match 'api/check', to: 'api#check', via: [:get, :post]
  match 'api/saveEvent', to: 'api#saveEvent', via: [:post]

  root to: 'dashboard#index'

  devise_for :users
  resources :users, :plans, :suites, :tests

end
