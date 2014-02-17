class app.views.CollectionListView extends Backbone.View
  tagName:'ul'

  attributes:
    class: 'topcoat-list topic-list list-li-has-thumb'

  initialize: ->
    self = this
    @model.on "reset", @render, this
    @model.on "add", (collection) ->
      self.$el.append new app.views.CollectionListItemView(model: collection).render().el


  render: ->
    @$el.empty()
    _.each @model.models, ((collection) ->
      @$el.append new app.views.CollectionListItemView(model: collection).render().el
    ), this
    this

