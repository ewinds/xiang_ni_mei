class app.models.CardCollection extends Backbone.Collection
  model: app.models.LocalCard

  sync: (method, model, options) ->
    if method is "read"
      cardDAO = new app.dao.CardDAO(app.db)
      cardDAO.findByUser @parent.id, (data) ->
        options.success data