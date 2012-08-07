function navigation_search() {
  var query = $('#search-input').val();

  // do ajax request here...
  $('#search-results').html("searching...");
  $.post("/home/search", {query: query}, function(data) {
    $('#search-results').html(data);
  })
}