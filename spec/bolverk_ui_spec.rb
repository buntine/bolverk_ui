require 'bolverk_ui'
require 'spec'
require 'spec/interop/test'
require 'sinatra/test'

set :environment, :test

describe 'Bolverk UI' do
  include Sinatra::Test

  it "renders index" do
    get '/'
    response.should be_ok
  end

  it "should render the registers"
  it "should render main memory"

end
