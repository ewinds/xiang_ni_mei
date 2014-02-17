app.utils.templates =
  load: (views, callback) ->
    deferreds = []
    $.each views, (index, view) ->
      if app.views[view]
        deferreds.push app.views[view].prototype.template = (model)->
          JST['templetes/' + view](model)
      else
        alert view + " not found"

    $.when(deferreds).done callback
