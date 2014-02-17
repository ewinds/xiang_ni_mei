class app.views.TopicListView extends Backbone.View
  tagName:'ul'

  attributes:
    class: 'topcoat-list topic-list list-li-has-thumb'

  initialize: ->
    self = this
    @model.on "reset", @render, this
    @model.on "add", (topic) ->
      self.$el.append new app.views.TopicListItemView(model: topic).render().el


  render: ->
    @$el.empty()
    _.each @model.models, ((topic) ->
      @$el.append new app.views.TopicListItemView(model: topic).render().el
    ), this
    this

