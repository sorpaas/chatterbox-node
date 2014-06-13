window.Group = Backbone.Model.extend
  url: "/groups"
  idAttribute: "_id"

  schema:
    name: 'Text'
    description: 'Text'


  initialize: ->
    this.topics = new TopicList()
    this.topics.url = "/groups/#{this.get('id')}/topics"
    this.topics.on("reset", this.updateCounts)

    this.members = new UserList()
    this.members.url = "/groups/#{this.get('id')}/members"
    this.members.on("reset", this.updateCounts)

  # Get the relationship for user in this group
  relationship_for: (user) ->
    if user.get('_id') == this.get('owner_id')
      "owner"
    else if $.inArray(user.get('_id'), this.get('group_member_ids')) != -1
      "member"
    else
      "stranger"
