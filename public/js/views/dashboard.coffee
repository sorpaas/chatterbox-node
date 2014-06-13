window.DashboardView = Backbone.View.extend
  tagName:             "div"
  className:           "view"
  id:                  "dashboard"

  template:            _.template $('#dashboard-tmpl').html()
  groupTmpl:           _.template $('#group-tmpl').html()
  groupNewTmpl:        _.template $('#group-new-tmpl').html()
  groupEditTmpl:       _.template $('#group-edit-tmpl').html()
  noticeLiTmpl:        _.template $('#notice-li-tmpl').html()
  alertsTmpl:          _.template $('#alerts-tmpl').html()

  events:
    "click #group-new-btn":     "renderGroupNew"
    "click #group-new-submit":  "groupCreate"
    "click .group-edit-btn":    "renderGroupEdit"
    "click .group-edit-submit": "groupUpdate"
    "click .group-join-btn":    "groupJoin"
    "click .group-quit-btn":    "groupQuit"
    "click .notice-li":         "navigateGroup"
    "click .group-destroy-btn": "groupDestroy"

  afterRender: ->
    this.resize()
    this.renderGroupList()
    this.renderAllGroupList()
    $("#dashboard").on "resize", this.resize

  resize: ->
    $(".groups, .notifications").css("min-height", "#{$(".view").height()- 3}px")

  renderGroupList: ->
    self = this
    groups = new GroupList()
    groups.fetch
      success: ->
        groups.each (group) ->
          group.set({relationship: group.relationship_for(current_user)})
          $("#my-groups-list").append(self.groupTmpl(group.toJSON()))
          $(self.el).append(self.groupEditTmpl(group.toJSON()))
          self.renderNotification(group)

  renderAllGroupList: ->
    self = this
    groups = new GroupList()
    groups.url = "/pub_groups"
    groups.fetch
      success: ->
        groups.each (group) ->
          group.set({relationship: "stranger"})
          $("#all-groups-list").append(self.groupTmpl(group.toJSON()))

  renderGroupNew: ->
    $('#group-new-or-join-modal').modal('toggle')
    $(this.el).append(this.groupNewTmpl()) unless $('#group-new-form').length > 0
    $('#group-new-modal').modal('toggle')

  groupCreate: ->
    self = this
    attributes = $("#group-new-form").serializeJSON()
    if attributes.name == ""
      $("#group-new-form .modal-body").
        prepend $(@alertsTmpl()).filter("#group-no-name").hide().fadeIn('fast')
      return
    else if attributes.name.search(/[.#$\\\/"']/) != -1
      $("#group-new-form .modal-body").
        prepend $(@alertsTmpl()).filter("#group-invalid-name").hide().fadeIn('fast')
        return
    $.ajax "/groups",
      files: $("#group-logo"),
      iframe: true,
      dataType: 'json',
      data: attributes
    .success (data) =>
      group = new Group()
      group.set($.extend(data, {relationship: "owner"}))
      $('#group-new-modal').modal('hide')
      $("#my-groups-list").append(self.groupTmpl(group.toJSON()))
      @$el.append @groupEditTmpl(group.toJSON())

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

  groupJoin: (e) ->
    group_id = $(e.currentTarget).data("group-id")
    group = new Group()
    group.url = "/groups/#{group_id}/join"
    group.save {},
      success: ->
        router.navigate("/groups/#{group_id}", true)

  groupQuit: (e) ->
    self = this
    group_id = $(e.currentTarget).data("group-id")
    group = new Group()
    group.url = "/groups/#{group_id}/quit"
    group.save {},
      type: "DELETE"
      success: ->
        group.set({relationship: "stranger"})
        $("#group-li-#{group_id}").remove()
        $("#all-groups-list").append(self.groupTmpl(group.toJSON()))

  groupDestroy: (e) ->
    group_id = $(e.currentTarget).data("group-id")
    bootbox.confirm "Are you sure? There is no going back.", (result) ->
      if result
        $.ajax "/groups/#{group_id}",
          type: 'DELETE'
          success: =>
            $("#group-li-#{group_id}").remove()
            $("#group-edit-modal-#{group_id}").modal("hide")
            $("#group-edit-form-#{group_id}").remove()

  renderNotification: (group) ->
    group_id = group.get('_id')
    $.ajax "/groups/#{group_id}/unread_comments_count",
      type: 'GET'
    .success (data) =>
      unless data == 0
        @renderUnreadCommentsCount(group_id, data)
        notice_li = $("#notice-list").find("[data-href$='#{group_id}']")
        if notice_li.length > 0
          notice_li.replaceWith(@noticeLiTmpl($.extend(group.toJSON(), {count: data})))
        else
          $("#notice-list").append(@noticeLiTmpl($.extend(group.toJSON(), {count: data})))

  renderUnreadCommentsCount: (group_id, count) ->
    $("#group-li-#{group_id}").find(".unread-count").html("<span class='badge badge-important'>#{count}</span>")

  navigateGroup: (e) ->
    router.navigate($(e.currentTarget).data("href"), true)
