#!/usr/bin/env node

'use strict';

var fs = require('fs');
var exec = require('child_process').exec;

fs.writeFile('public/postinstall.html',
  'Node app postinstall (SAMPLE_VARIABLE: ' + process.env.SAMPLE_VARIABLE + ')');

exec('cp bower_components/jquery/dist/jquery.js public/jquery.js');
