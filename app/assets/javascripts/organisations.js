function organisation_add_member_dialog() {
  var div = $('#dialog-tmp-medium');
  div.html("loading facebook friends... ");
  div.dialog("open");
  $.get("/organisations/dialog_add_member", function(data) {
    div.html(data);
  });
}

function organisation_edit() {
  var loc = window.location;
  window.location = loc + "/edit";
}