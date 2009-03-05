$(document).ready(function(){

  // Control the selected cell.
  $("#main_memory table.cells div").click(function(){
    $("#main_memory table.cells div").each(function(){
      $(this).removeClass("selected_cell");
    });
    $(this).addClass("selected_cell");
  });

  // Render the cell editable on a double-click.
  $("#main_memory table.cells div").dblclick(function(){
    if (!is_being_edited(this)) {
      hex = $(this).html();
      text_box = document.createElement("input");
      text_box.setAttribute("type", "text");
      text_box.setAttribute("value", hex);
      text_box.setAttribute("maxlength", "2");
      text_box.setAttribute("maxlength", "2");
      text_box.className = "cellcontents";
      text_box.style.width = '18px';

      // Store the hidden val so we can reference it later.
      current_val = document.createElement("input");
      current_val.setAttribute("type", "hidden");
      current_val.setAttribute("value", hex);

      $(this).html(text_box);
      $(this).append(current_val);
      $(text_box).focus();
    }
  });

  // Save the updated contents of a memory cell after
  // it has been modified.
  $('.cellcontents').livequery('blur', function(){
    original_value = $(this).next().val();
    value = $(this).val().rjust(2, "0");
    cell = $(this).parent();
    if (!is_valid_base_16(value)) { value = '00'; }

    if (value != original_value) {
      cell.html(value.toUpperCase());
      //$(this).parent().html('<img src="images/ajax-small.gif" />');
    } else
      cell.html(value.toUpperCase());

    // Configure the display for the cell based on the value we just stored in there.
    if (value != "00") { cell.removeClass("selected_cell"); cell.addClass("populated_cell"); }
    else { cell.removeClass("populated_cell"); cell.addClass("selected_cell"); }
  });

  // Returns true if 'cell' contains anything other base-16 string.
  function is_being_edited(cell) {
    return !is_valid_base_16($(cell).html());
  }
  
  // Returns true if 'value' is valid hexadecimal (length being 2).
  function is_valid_base_16(value) {
    valid_hex = /^[A-F0-9]{2}$/i;
    return valid_hex.test(value);
  }

});
