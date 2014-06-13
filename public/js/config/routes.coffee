window.Workspace = Backbone.Router.extend
  routes:
    "":                            "index"
    "dashboard":                   "dashboard"
    "groups/:id":                  "groupShow"
    "groups/:group_id/topics/:id": "topicShow"

  before: (route, params) ->
    # check user if signed in, in order to control request
    this.authenticate_user(route)
    # disabled browser scrollbar when show topic view, on the contrary enabled
    this.control_browser_scrollbar(route)



  index: ->
    main = new IndexView()
    $("#main").html(main.$el)
    main.render()

  dashboard: ->
    main = new Backbone.Layout
      template: "#application-layout"
      views:
        "#navbar-user": new NavbarUser()
        "#container":   new DashboardView()
    $("#main").html(main.$el)
    main.render()

  groupShow: (id) ->
    main = new Backbone.Layout
      template: "#application-layout"
      views:
        "#navbar-user": new NavbarUser()
        "#container":   new TopicView({group_id: id})
    $("#main").html(main.$el)
    main.render()

  topicShow: (group_id, id) ->
    main = new Backbone.Layout
      template: "#application-layout"
      views:
        "#navbar-user": new NavbarUser()
        "#container":   new TopicView({group_id: group_id, _id: id})
    $("#main").html(main.$el)
    main.render()


  authenticate_user: (route) ->
    if typeof signed_out is 'undefined' || signed_out == "no"
      window.current_user = new CurrentUser()
      current_user.fetch
        async: false
        success: =>
          if current_user.isNew()
            if route != "" then @navigate('', true)
          else
            if route == "" then @navigate('/dashboard', true)

  control_browser_scrollbar: (route) ->
    if route == "groups/:id" || route == "groups/:group_id/topics/:id"
      $("html").css("overflow", "hidden")
    else
      $("html").removeAttr("style")


jQuery ->
  window.router = new Workspace()
  Backbone.history.start({ pushState: true, root: '/' })

  # Globally capture clicks. If they are internal,
  # route them through Backbone's navigate method.
  $(document).on "click", "a[href^='/']", (e) ->
    e.preventDefault()
    router.navigate($(e.currentTarget).attr('href'), true)
    false
