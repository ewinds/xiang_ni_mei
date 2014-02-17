class app.views.CollectionListItemView extends Backbone.View
  tagName:"li"

  className:"topcoat-list__item"

  initialize: ->
    @model.on "change", @render, this
    @model.on "destroy", @close, this

  render: ->
    @$el.html @template(@model.attributes)
    this