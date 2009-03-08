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

  def read_emulator
    File.read(marshalled_emulator)
  end

  def write_emulator(emulator)
    session_file = File.open(marshalled_emulator, "w")
    session_file.write(Marshal.dump(emulator))
    session_file.close
  end
end

before do
  session[:key] ||= generate_session_key

  # Rather than keeping the whole emulator in the session,
  # its marshalled and stored locally, with a reference to
  # a unique key. On each request, the object is decoded for
  # usage.
  if File.exists?(marshalled_emulator)
    encoded_object = read_emulator
    bolverk = Marshal.load(encoded_object)
  else
    bolverk = Bolverk::Emulator.new
    write_emulator(bolverk)
  end

  @emulator = bolverk
end

# Thrown when invalid instructions are loaded.
error RuntimeError do
  @error_message = request.env['sinatra.error'].message
  erb :index
end

# Thrown when a non-existant memory address is referenced.
error Bolverk::InvalidMemoryAddress do
  @error_message = "#{request.env['sinatra.error'].message} (Did you run out of memory cells?)"
  erb :index
end

# Render the emulator.
get '/' do
  erb :index
end

# Render the "write program" dialog.
get '/program' do
  request.xhr? ? erb(:new_program, :layout => false) : erb(:index)
end

# Write a program to memory and save the emulator.
post '/program' do
  cell = params[:cell]
  instructions = (params[:instructions] || "").split(" ")
  @emulator.load_program_into_memory(cell, instructions)
  write_emulator(@emulator)
  erb :index
end

# Write to a memory cell and save the emulator.
post %r{/write/([a-fA-F0-9]{2})/([a-fA-F0-9]{2})} do
  cell = params[:captures][0]
  value = params[:captures][1]
  @emulator.memory_write(cell, value.clone)
  write_emulator(@emulator)
  body(value)
end
