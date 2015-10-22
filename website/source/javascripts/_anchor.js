/* global $ */ 'use strict';

$(function() {
  $(document).on('click', 'a[href^=#]', function() {
    var link = $(this),
        href = link.attr('href'),
        target = $(href),
        offset = href === '#' ? 0 : target.offset().top;

    if (target.length && target[0].tagName.toUpperCase() !== 'H2') {
      offset -= $('nav').height() + 5;
    }

    $('html, body').animate({ scrollTop: offset });

    if (history.pushState) {
      history.pushState({}, null, href === '#' ? '#' : href);
    }

    return false;
  });
});