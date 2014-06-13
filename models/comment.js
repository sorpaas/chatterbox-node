var mongoose = require('mongoose');

var Schema = mongoose.Schema;
var ObjectId = Schema.ObjectId;

var userSchema = require('./user');
var topicSchema = require('./topic');
var groupSchema = require('./group');

var commentSchema = new Schema({
  content: String,
  content_html: String,
  reader_ids: {type: Array, default: []},
  user: userSchema,
  topic: topicSchema
});

commentSchema.virtual('author').get(function() {
  return this.user.username;
});

commentSchema.virtual('author_avatar_url_64').get(function() {
  return this.user.avatar_url_64;
});
