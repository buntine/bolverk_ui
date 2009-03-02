$(document).ready(function(){

  // Control the selected cell.
  $("#main_memory table.cells div").click(function(){
    add_class = !$(this).hasClass("selected_cell");
    $("#main_memory table.cells div").each(function(){
      $(this).removeClass("selected_cell");
    });
    if (add_class)
      $(this).addClass("selected_cell");
  });

});
