var mongoose = require('mongoose');

var Schema = mongoose.Schema;
var ObjectId = Schema.ObjectId;

var commentSchema = require('./comment');
var topicSchema = require('./topic');
var userSchema = require('./user');

var groupSchema = new Schema({
  name: String,
  description: String,
  member_count: { type: Number, default: 0 },
  logo_url: String,
  owner: userSchema,
  topics: [ topicSchema ],
  group_members: [ userSchema ]
});

module.experts = groupSchema;
