'use strict';

var basePath = '../app/controllers';
var home = require(basePath + '/home');

module.exports = function(app) {
  app.use('/', home);
};
