var caminte = require('caminte');
var Schema = caminte.Schema;
var db = {}; //TODO add mongodb adapter

var schema = new Schema(db.driver, db);

var Group = schema.define('Group', {
  name: String,
  description: String
});

var Topic = schema.define('Topic', {
  title: String,
  description: String
});

var User = schema.define('User', {
  name: String,
  avatar: String
});

var Comment = schema.define('Comment', {
  content: String
});

var Member = schema.define('Member', {});

Group.hasMany(Topic, { as: 'topics', foreignKey: 'groupId' });
Topic.belongsTo(Group, { as: 'group', foreignKey: 'groupId' });

Group.hasMany(Member, { as: 'members', foreignKey: 'groupId'});
User.hasMany(Member, { as: 'members', foreignKey: 'userId' });
Member.belongsTo(Group, { as: 'group', foreignKey: 'groupId' });
Member.belongsTo(User, { as: 'user', foreignKey: 'userId' });

Group.prototype.users = function(){
  return this.members.map(function(x){
    return x.user;
  });
}

User.prototype.groups = function(){
  return this.members.map(function(x){
    return x.group;
  })aa
}
