var mongoose = require('mongoose');

var Schema = mongoose.Schema;
var ObjectId = Schema.ObjectId;

var Comment = new Schema({
  content: String,
  content_html: String,
  reader_ids: {type: Array, default: []}
});
