require 'rubygems'
require 'sinatra'
require 'bolverk'
require 'helpers/ui'
require 'output_catcher'

include Bolverk::Operations::ClassMethods

class Bolverk::UnknownEncodingType < Exception; end

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

  def die_and_render(message=nil)
    @error_message = request.env['sinatra.error'].message
    @error_message << " (#{message})" unless message.nil?
    erb :index
  end

  def encode_ascii_characters(characters)
    ascii_codes = []

    characters.each_byte do |code|
      ascii_codes << code.to_s(base=2).rjust(8, "0")
    end 

    ascii_codes
  end

  def increment_hex(hex_value)
    binary = hex_value.hex_to_binary(size=8)
    binary.increment!
    binary.binary_to_hex
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
  die_and_render
end

# Thrown when a non-existant memory address is referenced.
error Bolverk::InvalidMemoryAddress do
  die_and_render "Did you run out of memory cells?"
end

# Thrown when a non-existant operation is executed.
error Bolverk::UnknownOpCodeError do
  die_and_render "See the LANGUAGE_SPEC"
end

# Thrown when processor is cycled and the program counter is null.
error Bolverk::NullProgramCounterError do
  die_and_render "Is a program running?"
end

error Bolverk::OverflowError do
  die_and_render "See the LANGUAGE_SPEC for more info"
end

error Bolverk::UnknownEncodingType do
  die_and_render
end


# Render the emulator.
get '/' do
  erb :index
end

get '/program' do
  request.xhr? ? erb(:new_program, :layout => false) : erb(:index)
end

get '/program/encoder' do
  erb :encoding_helper, :layout => false
end

get '/readme' do
  erb :readme
end

get '/language_spec' do
  erb :language_spec
end

# Clear main memory, registers and flush stdout.
post '/reboot' do
  @emulator.reboot!
  session[:stdout] = ""
  save_and_render
end

# Clears the contents of stdout.
get '/flush' do
  session[:stdout] = ""
  erb :index
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

# Write a program to memory.
post '/program' do
  cell = params[:cell]
  instructions = (params[:instructions] || "").split(" ")
  @emulator.load_program_into_memory(cell, instructions)
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

# Write an encoded value to a particular memory cell.
post '/write/encode' do
  cell = params[:cell]
  type = params[:type]

  case type
    when "signed"
      decimal = (params[:value] =~ /^\-?\d+$/) ? params[:value].to_i : 0
      value = encode_twos_complement(decimal)
      @emulator.memory_write(cell, value)
    when "floating_point"
      decimal = (params[:value] =~ /^\-?[.\d]+$/) ? params[:value].to_f : 0
      value = encode_floating_point(decimal)
      @emulator.memory_write(cell, value)
    when "ascii"
      values = encode_ascii_characters(params[:value])

      # Store each encoded character in subsequent cells.
      values.each do |value|
        @emulator.memory_write(cell, value)
        cell = increment_hex(cell)
      end
    else
      raise Bolverk::UnknownEncodingType, "Unknown encoding type: #{type}"
  end
    
  save_and_render
end
