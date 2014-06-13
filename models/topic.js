var mongoose = require('mongoose');

var Schema = mongoose.Schema;
var ObjectId = Schema.ObjectId;

var commentSchema = require('./comment');
var groupSchema = require('./group');
var userSchema = require('./user');

var topicSchema = new Schema({
  title: String,
  group: groupSchema,
  owner: userSchema,
  comments: [ commentSchema ]
});

topicSchema.virtual('latest_ten_comments').get(function() {
  return this.comments.silce(this.comments.length - 10).reverse();
});

module.experts = topicSchema;
