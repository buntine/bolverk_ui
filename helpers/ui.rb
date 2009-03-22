helpers do

  # Displays each register with it's correct value from the emulator.
  def display_registers
    content = "<table align=\"center\" cellpadding=\"0\" cellspacing=\"0\" class=\"cells\">"
    (0..15).each do |cell|
      hex = cell.to_s(base=16).upcase
      value = @emulator.register_read(hex).binary_to_hex
      css = value.eql?("00") ? "empty_cell" : "populated_cell"
      content << "<tr><td><div id=\"r#{hex}\" class=\"#{css}\"><span>#{value}</span><span class=\"hex\">R#{hex}</span></div></td></tr>"
    end
    content << "</table>"

    content
  end

  # Displays each main memory cell with it's correct value from the emulator.
  def display_main_memory
    content = "<table align=\"center\" cellpadding=\"0\" cellspacing=\"0\" class=\"cells\">"
    (0..15).each do |row|
      content << "<tr>"
      (0..15).each do |cell|
        hex = ((row * 16) + cell).to_s(base=16).rjust(2, "0").upcase
        value = @emulator.memory_read(hex).binary_to_hex
        css = value.eql?("00") ? "empty_cell" : "populated_cell"

        # Display as program_cell if this cell is the next to be executed.
        unless @emulator.program_counter.nil?
          counter = @emulator.program_counter.hex
          if [counter, counter+1].include?(hex.hex)
            css = "program_cell"
          end
        end

        content << "<td><div id=\"#{hex}\" class=\"#{css}\"><span>#{value}</span><span class=\"hex\">#{hex}</span></div></td>"
      end
      content << "</tr>"
    end
    content << "</table>"

    content
  end

  # Displays a select with options for each hex value from 00 to FE/FF.
  def render_cell_select_box(allow_ff=false)
    content = "<select name=\"cell\" class=\"sml\">"
    max_value = allow_ff ? 255 : 254
    (0..max_value).each do |number|
      hex = number.to_s(base=16).rjust(2, "0").upcase
      content << "<option value=\"#{hex}\">#{hex}</option>"
    end
    content << "</select>"

    content
  end

end

