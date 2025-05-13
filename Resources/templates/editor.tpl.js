$("#picture").one("load", function() {
    setup("{filename}");
}).each(function() {
  if(this.complete) {
      //$(this).load(); // For jQuery < 3.0
      $(this).trigger('load'); // For jQuery >= 3.0
  }
});
