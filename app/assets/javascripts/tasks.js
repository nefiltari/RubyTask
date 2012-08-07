function task_add_member_dialog() {
  var div = $('#dialog-tmp-medium');
  div.html("Loading Members...");
  div.dialog("open");
  $.get("/tasks/new/dialog_add_member", function(data) {
    div.html(data);
  });
}