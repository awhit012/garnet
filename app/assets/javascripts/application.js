// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require select2
//= require jquery.stickytableheaders.min
//= require d3.min

//= require_tree .

$(".fold").on("click", function(e){
  // toggles url anchor
  // Actual "fold"ing is performed by CSS
  var hash = window.location.hash;
  if(hash == e.target.getAttribute('href')){
    e.preventDefault();
    window.location.hash = '#';
  }
});

$(".js-fold-without-anchor").on("click", function(e){
  e.preventDefault();
  $(this).toggleClass('folded');
  $(this).siblings("div").toggle();
});

var hash = window.location.hash
if(hash){
  hash = hash.split("-")
  if(hash[0]){
    hash = hash[0]
    $(hash).siblings("div").show();
    $('html, body').scrollTop($(""+ window.location.hash + "").offset().top);
  }
}
