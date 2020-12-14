require 'test_helper'

class MoviesControllerTest < ActionDispatch::IntegrationTest
  fixtures :omdb

  test 'should successfully show index page' do
    get '/movies'
    assert_response :success
  end

  test 'should have movies form' do
    get '/movies'
    assert_select 'form'
  end
end
