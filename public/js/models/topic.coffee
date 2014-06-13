window.Topic = Backbone.Model.extend
  url: '/topics'
  idAttribute: "_id"

  initialize: ->
    this.comments = new CommentList()
    this.comments.url = "/topics/#{this.id}/comments"
    this.comments.on("reset", this.updateCounts)
