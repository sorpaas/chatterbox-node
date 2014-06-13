window.TopicView = Backbone.View.extend
  tagName:               "div"
  className:             "view"
  id:                    "topic-view"

  attributes: ->
    "data-group-id":     @options.group_id

  template:              _.template $('#topic-tmpl').html()
  topicNewTmpl:          _.template $('#topic-new-tmpl').html()
  topicEditTmpl:         _.template $('#topic-edit-tmpl').html()
  commentTmpl:           _.template $('#comment-tmpl').html()
  topicNavTmpl:          _.template $('#topic-nav-tmpl').html()
  chatBoxTmpl:           _.template $('#chat-box-tmpl').html()
  topicGroupInfoTmpl:    _.template $('#topic-group-info-tmpl').html()
  topicMemberListLiTmpl: _.template $('#topic-member-list-li-tmpl').html()
  markdownTmpl:          _.template $('#markdown-tmpl').html()
  groupEditTmpl:         _.template $('#group-edit-tmpl').html()
  groupNotificationTmpl: _.template $('#group-notification-tmpl').html()
  alertsTmpl:            _.template $('#alerts-tmpl').html()

  events:
    "click #topic-new-btn":          "topicNew"
    "click #topic-edit-btn":         "topicEdit"
    "click #topic-new-submit":       "topicCreate"
    "click #topic-edit-submit":      "topicUpdate"
    "click #comment-content-submit": "commentCreate"
    "keypress :input":               "keypress"
    "click .group-edit-btn":         "renderGroupEdit"
    "click .group-edit-submit":      "groupUpdate"
    "click .group-destroy-btn":      "groupDestroy"
    "click #topic-delete-btn":       "topicDestroy"



  initialize: ->
    @groupModel = new Group({id: @options.group_id})

  afterRender: ->
    @groupModel.topics.on 'sync', (topics) =>
      current_topic = if @options._id then topics.findWhere({_id: @options._id}) else topics.first()
      @renderTopicNavs(topics, current_topic)
      @renderChatBox(current_topic)
      @$el.append(@topicEditTmpl(current_topic.toJSON())) if current_topic
      @renderCommentList(current_topic)
      @subscribe(current_topic)

    @groupModel.on 'sync', (group) =>
      $(".group-info").html(@topicGroupInfoTmpl(group.toJSON()))
      @$el.append(@groupEditTmpl(group.toJSON()))

    $("#container").append(@markdownTmpl())

    @resizeBothSides()
    @fetchGroupModel()
    @fetchTopicList()
    @fetchMemberList()

    $(window).on "resize", =>
      @resizeBothSides()
      @resizeComments()

  fetchTopicList: ->
    this.groupModel.topics.fetch()

  fetchGroupModel: ->
    @groupModel.url = "/groups/#{@options.group_id}"
    @groupModel.fetch()

  fetchMemberList: ->
    @groupModel.members.fetch
      success: (members) =>
        $(".member-list").html("")
        online_count = 0
        members.each (member) =>
          online_count += 1 if member.get('session_state') == "online"
          $(".member-list").append(@topicMemberListLiTmpl(member.toJSON()))
        $("#members-online-count").html(online_count)

  resizeBothSides: ->
    $(".topics, .users").css("height", "#{$(window).height() - 63}px")

  resizeComments: ->
    $("#comments").css("height", "#{$(window).height() - $("#comment-new-form").height() - 95}px")

  renderTopicNavs: (topics, current_topic) ->
    self = this
    topics.each (topic) ->
      if current_topic == topic
        css = "active"
      else
        self.renderUnreadCommentsCount(topic)
      $(".topic-list").append self.topicNavTmpl
        css: css
        group_id: topic.get('group_id')
        id: topic.id
        title: topic.get('title')

  renderChatBox: (topic) ->
    if topic
      @$(".chat-box").html(@chatBoxTmpl({topic: topic, group: @groupModel}))
      @$('.js-editor').markDownEditor()
      @$('.js-editor').autosize()
      @resizeComments()
      @$("#comment-new-form").on "resize", @resizeComments

  renderCommentList: (topic) ->
    if topic
      self = this
      topic.comments.fetch
        success: (comments) ->
          comments.each (comment) ->
            self.renderComment("comment", comment.toJSON())

  renderComment: (type, data) ->
    comments_el = @$("#comments")
    item_html = if type == "comment" then @commentTmpl(data) else @groupNotificationTmpl(data)
    comments_el.append(item_html)
    comments_el.animate
      scrollTop: comments_el.prop("scrollHeight") - comments_el.height()
      , 10

  topicNew: ->
    $(this.el).append(this.topicNewTmpl()) unless $('#topic-new-form').length > 0
    $('#topic-new-modal').modal('toggle')

  topicEdit: ->
    $('#topic-edit-modal').modal('toggle')

  topicCreate: ->
    self = this
    topic = new Topic()
    attributes = $.extend($("#topic-new-form").serializeJSON(), {group_id: this.groupModel.get('id')})
    if attributes.title == ""
      $("#topic-new-form .modal-body").
        prepend $(@alertsTmpl()).filter("#topic-no-title").hide().fadeIn('fast')
      return
    else if attributes.title.search(/[.#$\\\/"']/) != -1
      $("#topic-new-form .modal-body").
        prepend $(@alertsTmpl()).filter("#topic-invalid-title").hide().fadeIn('fast')
        return
    topic.save attributes,
      success: ->
        console.log attributes
        attributes =
          _id: topic.id
          title: attributes.title
        self.$el.append self.topicEditTmpl attributes
        $('#topic-new-modal').modal('hide')
        if $(".topic-list").html() == ""
          css = "active"
          self.renderChatBox(topic)
          self.subscribe(topic)
        $(".topic-list").append self.topicNavTmpl
          css: css
          group_id: topic.get('group_id')
          id: topic.id
          title: topic.get('title')

  topicUpdate: ->
    attributes = $("#topic-edit-form").serializeJSON()
    if attributes.title == ""
      $("#topic-edit-form .modal-body").
        prepend $(@alertsTmpl()).filter("#topic-no-title").hide().fadeIn('fast')
      return
    else if attributes.title.search(/[.#$\\\/"']/) != -1
      $("#topic-edit-form .modal-body").
        prepend $(@alertsTmpl()).filter("#topic-invalid-title").hide().fadeIn('fast')
        return
    topic = new Topic()
    topic.url = "/topics/#{attributes.id}"
    topic.save attributes, {type: "PUT"}
    $(".topic-title-#{attributes.id}").html(attributes.title)
    $("#topic-edit-modal").modal("hide")

  topicDestroy: (e) ->
    topic_id = @$(e.currentTarget).data("id")
    bootbox.confirm "Are you sure? There is no going back.", (result) ->
      if result
        $.ajax "/topics/#{topic_id}",
          type: "DELETE"
          success: =>
            $("#topic-li-#{topic_id}").remove()
            topicList = $(".topoic-list")
            if topicList.length != 0
              topicList.children().first().children().first().click()
            else
              window.location.href = window.location.href.replace /(.+)\/topics\/.+/, "$1"


  commentCreate: ->
    attributes = $("#comment-new-form").serializeJSON()
    unless attributes.content.replace(/(^\s*)|(\s*$)/g, "") == ""
      comment = new Comment()
      comment.save attributes
      $("#comment-content").val("")

  subscribe: (topic) ->
    if topic
      if typeof subscription isnt 'undefined' then subscription.cancel()
      window.subscription = faye_client.subscribe "/topics/#{topic.id}/comments", (data) =>
        @renderComment(data.type, $.parseJSON(data.item))
        @fetchMemberList() if data.type == "notification"

  keypress: (e) ->
    # ctrl + enter, newline
    # enter, invoke commentCreate function
    if e.ctrlKey && e.which == 13 || e.which == 10
      $("#comment-content").appendVal("\n")
    else if e.which == 13 || e.which == 10
      this.commentCreate()
      false

  renderGroupEdit: (e) ->
    group_id = $(e.currentTarget).data("group-id")
    $("#group-edit-modal-#{group_id}").modal("toggle")

  groupUpdate: (e) ->
    group_id = $(e.currentTarget).data("group-id")
    attributes = $("#group-edit-form-#{group_id}").serializeJSON()
    if attributes.name == ""
      $("#group-edit-form-#{group_id} .modal-body").
        prepend $(@alertsTmpl()).filter("#group-no-name").hide().fadeIn('fast')
      return
    else if attributes.name.search(/[.#$\\\/"']/) != -1
      $("#group-edit-form-#{group_id} .modal-body").
        prepend $(@alertsTmpl()).filter("#group-invalid-name").hide().fadeIn('fast')
        return
    $.ajax "/groups/#{group_id}",
      files: $("#group-logo-field-#{group_id}"),
      iframe: true,
      dataType: 'json',
      data: attributes
    .success (data) ->
      $(".group-name-#{group_id}").html(attributes.name)
      $("#group-desc-#{group_id}").html(attributes.description)
      $(".group-logo-64-#{group_id}").attr("src", data.logo_url_64)
      $(".group-logo-32-#{group_id}").attr("src", data.logo_url_32)
      $("#group-edit-modal-#{group_id}").modal("hide")

  groupDestroy: (e) ->
    group_id = $(e.currentTarget).data("group-id")
    if confirm "Are you sure?"
      $.ajax "/groups/#{group_id}",
        type: 'DELETE'
        success: =>
          $("#group-edit-modal-#{group_id}").modal("hide")
          router.navigate('/dashboard', true)

  renderUnreadCommentsCount: (topic) ->
    topic_id = topic.get('_id')
    $.ajax "/topics/#{topic_id}/unread_comments_count",
      type: 'GET'
    .success (data) ->
      if data != 0
        $("#topic-li-#{topic_id}").append("<span class='badge badge-important'>#{data}</span>")
