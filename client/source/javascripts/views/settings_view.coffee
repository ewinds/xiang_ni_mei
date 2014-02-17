class app.views.SettingsView extends Backbone.View
  events:
    'tap a': 'handleTapLink'
    'click a': 'preventDefault'

  render: ->
    @$el.html @template(user_id: @model.id)
    this

  handleTapLink: (e)->
    app.utils.event.handleTapLink(e)

  preventDefault: (e)->
    e.preventDefault()