class app.views.CardListView extends Backbone.View
  tagName:'ul'

  attributes:
    class: 'topcoat-list topic-list list-li-has-thumb'

  initialize: ->
    self = this
    @model.on "reset", @render, this
    @model.on "add", (card) ->
      self.$el.append new app.views.CardListItemView(model: card).render().el


  render: ->
    @$el.empty()
    if _.size(@model.models)
      _.each @model.models, ((card) ->
        @$el.append new app.views.CardListItemView(model: card).render().el
      ), this
    else
      @$el.append "<p class='message'>你还没有留下任何足迹</p>"
    this

