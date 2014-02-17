class app.views.HomeView extends Backbone.View
  events:
    'tap a': 'handleTapLink'
    'click a': 'preventDefault'

  initialize: ->
    collections = new app.models.CollectionCollection()
    collections.fetch
      reset: true
    @collectionsView = new app.views.CollectionListView(model: collections)

  render: ->
    @$el.html @template()
    $('.scroller', @el).append(@collectionsView.render().el)
    this

  handleTapLink: (e)->
    app.utils.event.handleTapLink(e)

  preventDefault: (e)->
    e.preventDefault()

