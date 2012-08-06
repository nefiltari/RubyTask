function navigation_search() {
  var query = $('#search-input').val();

  // do ajax request here...
  $('#search-results').html("searching...");
  setTimeout(function () {
    $('#search-results').html("<ul><li>Result 1</li><li>Result 2</li><li>Result 3</li></ul>")
  }, 1000);
}