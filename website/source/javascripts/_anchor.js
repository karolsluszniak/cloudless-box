/* global $ */ 'use strict';

var scrollToHref = function(href) {
  var target = $(href),
      top = href === '#' ? 0 : target.offset().top - ($('nav').height() + 8);

  $('html, body').animate({ scrollTop: top });
};

$(function() {
  $(document).on('click', 'a[href^=#]', function() {
    var link = $(this),
        href = link.attr('href');

    scrollToHref(href);

    if (history.pushState) {
      history.pushState({}, null, href === '#' ? '/' : href);
    }

    return false;
  });
});

$(window).load(function() {
  if (location.hash && location.hash.length > 0) {
    scrollToHref(location.hash);
  }
});
