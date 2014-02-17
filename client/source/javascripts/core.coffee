Core = Core or {}
Core =
  init: ->

  api:
    submit: (ajax_url, ajax_data, callback) ->
      auth_token = ""
      auth_token = Core.auth.authToken.get()  if Core.auth.isAuthenticated()
      $.ajax
        type: "GET"
        dataType: "json"
        crossDomain: true
        url: Core.base_url + ajax_url
        cache: false

      #data: ajax_data,
        data: "auth_token=" + auth_token + "&" + ajax_data
        success: (data) ->
          callback.onSuccess.call this, data  if typeof callback.onSuccess is "function"

        error: (data, status) ->
          if typeof callback.onError is "function"
            return callback.onDenied.call(this, data)  if data.status is "403"
            callback.onError.call this, data

        complete: (data) ->
          callback.onComplete.call this, data  if typeof callback.onComplete is "function"

        denied: (data) ->
          callback.onDenied.call this, data  if typeof callback.onDenied is "function"

  authenticate:
    onSubmit: (form_obj, callback) ->
      ajax_url = form_obj.attr("action")
      ajax_data = form_obj.serialize()
      Core.api.submit ajax_url, ajax_data,
        onSuccess: callback.onSuccess
        onError: callback.onError
        onDenied: callback.onDenied
        onComplete: callback.onComplete

  base_url: "http://10.32.92.109:3000/"

$ Core.init
window.Core = Core
