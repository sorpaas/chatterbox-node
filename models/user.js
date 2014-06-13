var md5 = require('MD5');
var mongoose = require('mongoose');

var Schema = mongoose.Schema;
var ObjectId = Schema.ObjectId;

var commentSchema = require('./comment');
var topicSchema = require('./topic');
var groupSchema = require('./group');

var userSchema = new Schema({
  username: String,
  email: String,
  use_gravatar: Boolean,
  raw_avatar_url_16: String,
  raw_avatar_url_32: String,
  raw_avatar_url_64: String,
  groups: [ groupSchema ],
  topics: [ topicSchema ],
  participating_groups: [ groupSchema ]
});

userSchema.virtual('avatar_url_16').get(function() {
  if (this.use_gravatar) {
    return "//gravatar.com/avatar/" + md5(this.email) + ".png?s=16";
  } else {
    return this.raw_avatar_url_16;
  }
});

userSchema.virtual('avatar_url_32').get(function() {
  if (this.use_gravatar) {
    return "//gravatar.com/avatar/" + md5(this.email) + ".png?s=32";
  } else {
    return this.raw_avatar_url_32;
  }
});

userSchema.virtual('avatar_url_64').get(function() {
  if (this.use_gravatar) {
    return "//gravatar.com/avatar/" + md5(this.email) + ".png?s=64";
  } else {
    return this.raw_avatar_url_64;
  }
});

module.exports = userSchema;
