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
    hex = $(this).text();
    text_box = document.createElement("input");
    text_box.setAttribute("type", "text");
    text_box.setAttribute("value", hex);
    text_box.style.width = '18px';
    $(this).html(text_box);
  });

});
