function projects_edit() {
  var loc = window.location.toString().split("/");
  var proj = loc.pop();
  var org = loc.pop();
  window.location = "/projects/"+org+"/"+proj+"/edit";
}

function projects_leave() {
  var loc = window.location;
  window.location = loc + "/leave";
}

function projects_join() {
  var loc = window.location;
  window.location = loc + "/join";
}

function projects_invite() {
  var loc = window.location.toString().split("/");
  var proj = loc.pop();
  var org = loc.pop();
  var div = $('#dialog-tmp-small');
  div.html("loading member ...");
  div.dialog("open");
  $.get("/projects/"+org+"/"+proj+"/dialog_add_member", function(data) {
    div.html(data);
  })
}

function projects_add_member_with_id(id) {
  var tr = $('tr[member_id='+id+']');
}