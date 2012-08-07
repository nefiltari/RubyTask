function task_add_member_dialog() {
  var div = $('#dialog-tmp-confirm');
  div.html("Loading Members...");
  div.dialog("open");
  $.get(window.location + "/dialog_add_member", function(data) {
    div.html(data);
  });
}