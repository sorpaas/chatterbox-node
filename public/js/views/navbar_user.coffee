window.NavbarUser = Backbone.View.extend
  tagName:   "ul"
  className: "nav"

  template: _.template $('#navbar-user-tmpl').html()

  events:
    "click #sign-out-link": "signOut"

  serialize: ->
    username: current_user.get("username")
    avatar_url_32: current_user.get("avatar_url_32")

  signOut: ->
    $.ajax '/sign_out',
      type: 'DELETE'
    .success (data) ->
      window.signed_out = "yes"
      router.navigate('', true)
