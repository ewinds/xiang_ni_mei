class app.views.CollectionView extends Backbone.View
  events:
    'tap .back-button': 'back'
    'tap a': 'handleTapLink'
    'click a': 'preventDefault'

  render: ->
    @$el.html @template(@model.toJSON())
    @model.topics.fetch()
    $('.scroller', @el).append(new app.views.TopicListView(model: @model.topics).render().el)
    this

  back: (event)->
    event.preventDefault()
    window.history.back();

  handleTapLink: (e)->
    app.utils.event.handleTapLink(e)

  preventDefault: (e)->
    e.preventDefault()