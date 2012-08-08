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
    $('#dialog-organisations').dialog("open");
    $('#dialog-organisations').html("loading...");
    $.get("/organisations/dialog", function(data) {
      $('#dialog-organisations').html(data);
      $('.my-a-button').button();
    })
  });

  $('#navigation-3').click(function() {
    window.location = "/mytasks"
  });

  //$('#navigation-4').click(window.location = "/messages");
  
  $('#navigation-5').click(function () {
    $('#dialog-search').dialog("open")
  })

  $('button').button();
  $('.my-a-button').button();
  $('input[type="submit"]').button();
  $('#tasks-add-member').button();
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
  $('#dialog-search').dialog({
    autoOpen: false,
    height: 500,
    width: 600,
    modal: true,
    show: "clip",
    hide: "clip",
    title: "Search..."
  });
  $('#dialog-tmp-small').dialog({
    autoOpen: false,
    height: 200,
    width: 300,
    modal: true,
    show: "clip",
    hide: "clip",
    title: "RubyTask asks..."
  });
  $('#dialog-tmp-medium').dialog({
    autoOpen: false,
    height: 500,
    width: 600,
    modal: true,
    show: "clip",
    hide: "clip",
    title: "RubyTask asks..."
  });
  $('#dialog-tmp-large').dialog({
    autoOpen: false,
    height: 700,
    width: 600,
    modal: true,
    show: "clip",
    hide: "clip",
    title: "RubyTask asks..."
  });
  $('#dialog-tmp-confirm').dialog({
    autoOpen: false,
    height: 500,
    width: 600,
    modal: true,
    show: "clip",
    hide: "clip",
    title: "Member",
    buttons: {
      "Save": function() {
        member = new Array()
        $("#member-list").empty();
        $("#project-member-list :checkbox").filter(":checked").each(function(index) {
          $("#member-list").append("<li><b>" + $(this).parent().text() + "</b></li>");
          member.push($(this).val());
        });
        $("#member-list").append('<input name="workers" type="hidden" value="' + member.join(',') + '" />');
        $('#dialog-tmp-confirm').dialog("close");
      }
    }
  });
}

function navigation_dialog_organisations_open() {
  $('#dialog-organisations').html("loading... <img src='/assets/loading.gif' alt='loading animation' />");
  $('#dialog-organisations').dialog("open");
  $.get("/organisations/dialog", function(data) {
    $('#dialog-organisations').html(data);
    $('.my-a-button').button();
  })
}