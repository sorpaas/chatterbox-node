// express magic
var express = require('express');
var app = express();
var server = require('http').createServer(app)
var io = require('socket.io').listen(server);
var device = require('express-device');
var routes = require('./routes');

var runningPortNumber = process.env.PORT || 5678;

routes(app);
sockets(io);

server.listen(runningPortNumber);
