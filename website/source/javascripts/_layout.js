/* global $ */ 'use strict';

$(function() {
  var content = $('article');

  content.find('table').wrap('<div class="table-wrapper">');
  content.find('a:not([href^=#])').attr('target', '_blank');
  content.find('h1').replaceWith($('<h2>').text('Intro'));
  content.find('h2, h3, h4, h5, h6').each(function() {
    var header = $(this),
        id = header.text().toLowerCase().replace(/\s/g, '-').replace(/[^\w-]/g, ''),
        uniqId = id, uniqIndex = 0;

    while ($('#' + uniqId).length) {
      uniqId = [id, ++uniqIndex].join('-');
    }

    header.attr('id', uniqId);
    header.prepend('<a class="header-anchor" href="#' + uniqId + '">' +
      '<i class="fa fa-link" /></a>');
  });
});
