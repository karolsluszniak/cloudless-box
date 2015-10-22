/* global $ */ 'use strict';

$(function() {
  var header = $('#header');

  header.on('click', 'a.learn-more', function() {
    $('html, body').animate({ scrollTop: $(window).height() });

    return false;
  });
});
