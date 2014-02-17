class app.models.CollectionCollection extends Backbone.Collection
  model: app.models.Collection

  sync: (method, model, options) ->
    if method is "read"
      collectionDAO = new app.dao.CollectionDAO(app.db)
      collectionDAO.findAll (data) ->
        options.success data