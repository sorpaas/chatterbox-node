window.IndexView = Backbone.View.extend
  tagName:   "div"
  className: "home-box"

  template: _.template $('#index-tmpl').html()

  events:
    "click #sign-in-submit": "signIn"
    "keypress :input":       "keypress"

  signIn: ->
    $.post '/sign_in', $("#sign-in-form").serialize(), (data) =>
      if data
        window.signed_out = "no"
        router.navigate('/dashboard', true)
      else
        sign_in_form_el = @$("#sign-in-form")
        sign_in_form_el.find(".field").addClass("error")
        sign_in_form_el.find(".errors").show()

  keypress: (e) ->
    if e.which == 13 || e.which == 10
      @signIn()
