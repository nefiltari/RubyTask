function task_add_member_dialog() {
  var div = $('#dialog-tmp-confirm');
  div.html("Loading Members...");
  div.dialog("open");
  $.get(window.location + "/dialog_add_member", function(data) {
    div.html(data);
  });
}

function task_complete() {
  loc = window.location
  window.location = loc + "/complete"
}

function task_edit() {
  loc = window.location
  window.location = loc + "/edit"
}

function task_remove() {
  loc = window.location
  window.location = loc + "/destroy"
}