'use strict';

var express = require('express');
var router  = express.Router();

router.get('/', function(req, res) {
  res.render('home/show');
});

module.exports = router;
