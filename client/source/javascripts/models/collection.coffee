class app.models.Collection extends Backbone.Model
  initialize: ->
    @topics = new app.models.TopicCollection()
    @topics.parent = this

  sync: (method, model, options) ->
    if method is "read"
      collectionDAO = new app.dao.CollectionDAO(app.db)
      collectionDAO.findById parseInt(this.id), (data) ->
        options.success data
