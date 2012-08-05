$(document).ready(function() {
  // hover effect
  $('.navigation-stretchbox').hover(function() {
    $(this).addClass("navigation-hover");
  }, function() {
    $(this).removeClass("navigation-hover");
  });

  // prepare dialog windows
  navigation_dialogs_init();

  //click handler
  $('#navigation-1').click(function() {
    window.location = "/";
  });
  $('#navigation-2').click(function() {
    $('#dialog-organisations').dialog("open")
  });
  //$('#navigation-3').click(window.location = "/tasks");
  //$('#navigation-4').click(window.location = "/messages");

  $('button').button();
});

function navigation_dialogs_init() {
  $('#dialog-organisations').dialog({
    autoOpen: false,
    height: 350,
    width: 500,
    modal: true,
    show: "clip",
    hide: "clip",
    title: "My Organisations"
  });
}