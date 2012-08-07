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