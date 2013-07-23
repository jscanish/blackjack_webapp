$(document).ready(function() {
  player_hits();
  player_stays();
  dealer_turn();
});

function player_hits() {
  $(document).on("click", "form#hit_form input", function() {
    $.ajax({
      type: "POST",
      url: "/game/hit",
    }).done(function(msg) {
      $("#game").replaceWith(msg)
    });
    return false;
  });
}

function player_stays() {
  $(document).on("click", "form#stay_form input", function() {
    $.ajax({
      type: "POST",
      url: "/game/stay",
    }).done(function(msg) {
      $("#game").replaceWith(msg)
    });
    return false;
  });
}

function dealer_turn() {
  $(document).on("click", "form#dealer_button input", function() {
    $.ajax({
      type: "POST",
      url: "/game/dealer",
    }).done(function(msg) {
      $("#game").replaceWith(msg)
    });
    return false;
  });
}
