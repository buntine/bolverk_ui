require 'rubygems'
require 'sinatra'
require 'bolverk'
require 'helpers/ui'

enable :sessions

helpers do
  def generate_session_key
    (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
  end

  def marshalled_emulator
    File.join("tmp/sessions", session[:key])
  end
end

before do
  session[:key] ||= generate_session_key

  # Rather than keeping the whole emulator in the session,
  # its marshalled and stored locally, with a reference to
  # a unique key. On each request, the object is decoded for
  # usage.
  if File.exists?(marshalled_emulator)
    encoded_object = File.read(marshalled_emulator)
    bolverk = Marshal.load(encoded_object)
  else
    bolverk = Bolverk::Emulator.new
    session_file = File.open(marshalled_emulator, "w")
    session_file.write(Marshal.dump(bolverk))
    session_file.close
  end

  @emulator = bolverk
end

get '/' do
  erb :index
end
