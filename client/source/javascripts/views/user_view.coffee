class app.views.UserView extends Backbone.View
  events:
    'tap #sign_out_button': 'signOut'
    'tap a': 'handleTapLink'
    'click a': 'preventDefault'

  render: ->
    @$el.html @template(_.extend(@model.toJSON(), 'user_id': @model.id))
    this

  signOut: ->
    $('.ui-loader').show()

  handleTapLink: (e)->
    app.utils.event.handleTapLink(e)

  preventDefault: (e)->
    e.preventDefault()
