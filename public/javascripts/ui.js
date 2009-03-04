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
      $(this).html(text_box);
    }
  });

  // Save the updated contents of a memory cell after
  // it has been modified.
  $('.cellcontents').livequery('blur', function(){
    alert($(this).val());
  });

  // Helper method.
  // Returns true if the passed-in cell contains anything other than a 2-byte string.
  function is_being_edited(cell) {
    return $(cell).html().length > 2;
  }

  
});
