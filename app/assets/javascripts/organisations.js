function organisation_add_member_dialog() {
  var div = $('#dialog-tmp-medium');
  div.html("loading facebook friends... ");
  div.dialog("open");
  var org = window.location.toString().split("/").pop();
  $.get("/organisations/"+org+"/dialog_add_member", function(data) {
    div.html(data);
  });
}

function organisation_edit() {
  var loc = window.location;
  window.location = loc + "/edit";
}

function organisation_join() {
  var loc = window.location;
  window.location = loc + "/join";
}

function organisation_leave() {
  var loc = window.location;
  window.location = loc + "/leave";
}

function organisation_add_project() {
  var org = window.location.toString().split("/").pop();
  window.location = "/projects/"+org+"/new";
}

function organisation_create_task() {
  var loc = window.location.toString().split("/");
  var id = loc.pop();
  window.location = "/tasks/" + id + "/<global>/new";
}