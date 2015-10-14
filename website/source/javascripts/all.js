/*= require_tree . */
/* global $ */ 'use strict';

$(function() {
  var content = $('#content');

  content.find('h1').remove();

  content.find('h2, h3, h4, h5, h6').each(function() {
    var header = $(this),
        id = header.text().toLowerCase().replace(/\s/g, '-').replace(/[^\w-]/g, '');

    header.attr('id', id);

    header.prepend('<a class="header-anchor" href="#' + id + '">➜</a>');
  });

  content.find('table').wrap('<div class="table-wrapper">');
});