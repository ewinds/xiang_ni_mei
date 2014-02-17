class app.models.Topic extends Backbone.Model
  sync: (method, model, options) ->
    if method is "read"
      topicDAO = new app.dao.TopicDAO(app.db)
      topicDAO.findById parseInt(this.id), (data) ->
        options.success data