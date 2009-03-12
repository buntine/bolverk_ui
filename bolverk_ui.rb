require 'rubygems'
require 'sinatra'
require 'bolverk'
require 'helpers/ui'
require 'output_catcher'

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

  def save_and_render
    write_emulator(@emulator)
    erb :index
  end
end

before do
  session[:key] ||= generate_session_key
  session[:stdout] ||= ""

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

# Thrown when a non-existant operation is executed.
error Bolverk::UnknownOpCodeError do
  @error_message = "#{request.env['sinatra.error'].message} (See the LANGUAGE_SPEC)"
  erb :index
end

# Thrown when processor is cycled and the program counter is null.
error Bolverk::NullProgramCounterError do
  @error_message = "#{request.env['sinatra.error'].message} (Is a program running?)"
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

get '/readme' do
  erb :readme
end

get '/language_spec' do
  erb :language_spec
end

# Write a program to memory.
post '/program' do
  cell = params[:cell]
  instructions = (params[:instructions] || "").split(" ")
  @emulator.load_program_into_memory(cell, instructions)
  save_and_render
end

# Clear main memory, registers and flush stdout.
post '/reboot' do
  @emulator.reboot!
  session[:stdout] = ""
  save_and_render
end

# Initialise a program in the processor.
post %r{/program/start/([a-fA-F0-9]{2})} do
  cell = params[:captures][0]
  @emulator.start_program(cell)
  save_and_render
end

# Perform a machine cycle and render the effects.
post '/program/step' do
  session[:stdout] << OutputCatcher.catch_out do
    @emulator.perform_machine_cycle
  end
  save_and_render
end

# Write to a memory cell.
post %r{/write/([a-fA-F0-9]{2})/([a-fA-F0-9]{2})} do
  cell = params[:captures][0]
  value = params[:captures][1]
  @emulator.memory_write(cell, value.clone)
  write_emulator(@emulator)
  value
end
