class app.models.TopicCollection extends Backbone.Collection
  model: app.models.Topic

  sync: (method, model, options) ->
    if method is "read"
      topicDAO = new app.dao.TopicDAO(app.db)
      topicDAO.findByCollection @parent.id, (data) ->
        options.success data