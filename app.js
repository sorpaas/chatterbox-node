// express magic
var express = require('express');
var app = express();
var server = require('http').createServer(app)
var io = require('socket.io').listen(server);
var device = require('express-device');
var routes = require('./routes');
var mongo = require('mongojs');

var runningPortNumber = process.env.PORT || 5678;
var databaseUrl = process.env.DATABASE_URL;
var databaseCollections = ["sessions", "users", "groups", "topics", "comments", "notifications"];
var db = mongo.connect(databaseUrl, databaseCollections);

routes(app, db);
sockets(io, app, db);

server.listen(runningPortNumber);
