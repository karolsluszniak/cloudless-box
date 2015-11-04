'use strict';

var express = require('express');
var routes = require('./routes');
var app = express();

app.set('views', './app/views');
app.set('view engine', 'jade');
app.locals.basedir = app.get('views');

routes(app);

module.exports = app;
