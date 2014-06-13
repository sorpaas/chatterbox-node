$.fn.serializeJSON = ->
  json = {}
  $.map $(this).serializeArray(), (n, i) ->
    json[n['name']] = n['value']
  json

$.fn.appendVal = (value) ->
  $(this).val (i, val) -> val + value
