class app.views.CardListItemView extends Backbone.View
  tagName: "li"

  className: "topcoat-list__item"

  initialize: ->
    @model.on "change", @render, this
    @model.on "destroy", @close, this

  render: ->
    updated_at = @formatDate(@model.get('updated_at'))
    @$el.html @template(_.extend(@model.omit('updated_at'), updated_at: updated_at))
    this

  formatDate: (date_string)->
    date = new Date(date_string)
    date.Format('yyyy年MM月dd日 hh时mm分')