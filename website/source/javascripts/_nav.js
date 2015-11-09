/* global $ */ 'use strict';

var nav, $window;

var refreshNav = function() {
  var show = $window.scrollTop() >= $window.height() - 20;

  nav.toggleClass('visible', show);
};

$(function() {
  nav = $('<nav>');
  $window = $(window);

  var links = $('<div class="links">').appendTo(nav);

  $('h2').each(function() {
    var header = $(this),
        link = $('<a href="#' + header.attr('id') + '">');

    link.text(header.text().replace(/➜/g, ''));
    links.append(link);
  });

  $('header .nav').clone().appendTo(links);

  links.prepend($('<a href="#">').text('Home'));

  $('body').append(nav);

  $window.scroll(refreshNav);
  $window.resize(refreshNav);
  refreshNav();
});
