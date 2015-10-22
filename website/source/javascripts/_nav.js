/* global $ */ 'use strict';

$(function() {
  var nav = $('<nav>'),
      links = $('<div class="links">').appendTo(nav),
      $window = $(window);

  $('h2').each(function() {
    var header = $(this),
        link = $('<a href="#' + header.attr('id') + '">');

    link.text(header.text().replace(/➜/g, ''));
    links.append(link);
  });

  links.prepend($('<a href="#">').text('Home'));

  $('body').append(nav.hide());

  $window.scroll(showOrHide);
  $window.resize(showOrHide);
  showOrHide();

  function showOrHide() {
    var visible = nav.is(':visible'),
        show = $window.scrollTop() >= $window.height() - 20;

    if (visible && !show) {
      nav.fadeOut();
    } else if (!visible && show) {
      nav.fadeIn();
    }
  }
});
