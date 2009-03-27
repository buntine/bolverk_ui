$(document).ready(function(){

  // Highlight the selected cell.
  $("#main_memory table.cells div").click(function(){
    $("#main_memory table.cells div").each(function(){
      $(this).removeClass("selected_cell");
    });
    $(this).addClass("selected_cell");

    hex = $(this).children("span:first").html();
    if (is_valid_base_16(hex) && hex != "00") {
      $("#initialize_program").removeAttr("disabled");
      $("#initialize_program").parent().attr("action", "/program/start/" + $(this).children("span:last").html())
    } else
      $("#initialize_program").attr("disabled", "disabled");
  });

  // Render the cell editable on a double-click.
  $("#main_memory table.cells div").dblclick(function(){
    cell = $(this).children("span:first");
    if (!is_being_edited(cell)) {
      hex = $(cell).html();
      text_box = document.createElement("input");
      text_box.setAttribute("type", "text");
      text_box.setAttribute("value", hex);
      text_box.setAttribute("maxlength", "2");
      text_box.setAttribute("maxlength", "2");
      text_box.className = "cellcontents";

      // Store the hidden val so we can reference it later.
      current_val = document.createElement("input");
      current_val.setAttribute("type", "hidden");
      current_val.setAttribute("value", hex);

      $(cell).html(text_box);
      $(cell).append(current_val);
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
      $.post("/write/" + cell.parent().attr("id") + "/" + value.toUpperCase(), {}, function(data) {
        cell.html(data);
      });
    } else
      cell.html(value.toUpperCase());

    // Configure the display for the cell based on the value we just stored in there.
    if (value != "00") { cell.parent().removeClass("selected_cell"); cell.parent().addClass("populated_cell"); }
    else { cell.parent().removeClass("populated_cell"); cell.parent().addClass("selected_cell"); }
  });

  // Validates the machine instructions in the "New Program" form.
  $('#program_form').livequery("submit", function(){
    valid_instructions = /^([A-F0-9]{4}\s?)+$/i;
    
    // Display a big error message to the user.
    if ( $("#instructions").val() == "" || !valid_instructions.test($("#instructions").val()) ) {
      display_thickbox_error("The entered program is invalid! Please enter only 4-character instructions in base-16.");
      return false;
    }

    return true;
  });

  // Validates the data in the "Encodings Helper" form.
  $('#encoder_form').livequery("submit", function(){
    valid_decimal = /^\-?\d+$/;
    valid_float = /^\-?[.\d]+$/;
    
    // Validate the input appropriate depending on the selected "type".
    switch ( $('select#type option:selected').val() ) {
      case "signed":
        if ( !valid_decimal.test($("#value").val()) ) {
          display_thickbox_error("Please enter a valid decimal value in the 'Value' field.");
          return false;
        }
      case "floating_point":
        if ( !valid_float.test($("#value").val()) ) {
          display_thickbox_error("Please enter a valid decimal value (with a radix) in the 'Value' field.");
          return false;
        }
      case "ascii":
        if ( $('#value').val() == "" ) {
          display_thickbox_error("Please enter one or more valid characters in the 'Value' field.");
          return false;
        }
    }

    return true;
  });

  $('.close-dialog-link').click(function(){
    $(this).parent().fadeOut('slow');
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

  function display_thickbox_error(message) {
    error_div = document.createElement("div");
    error_div.className = "thickbox_error";
    error_div.innerHTML = message;
    $("#thickbox_error_container").html(error_div);
    setTimeout("$('.thickbox_error').fadeOut('slow');", 3300);
  }

});
