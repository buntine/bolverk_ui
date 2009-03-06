helpers do

  # Displays each register with it's correct value from the emulator.
  def display_registers
    content = "<table align=\"center\" cellpadding=\"0\" cellspacing=\"0\" class=\"cells\">"
    (0..15).each do |cell|
      hex = cell.to_s(base=16).upcase
      value = @emulator.register_read(hex).binary_to_hex
      content << "<tr><td><div><span>#{value}</span><span class=\"hex\">#{hex}</span></div></td></tr>"
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
        content << "<td><div id=\"#{hex}\"><span>#{value}</span><span class=\"hex\">#{hex}</span></div></td>"
      end
      content << "</tr>"
    end
    content << "</table>"

    content
  end
end
