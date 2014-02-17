class app.models.LocalCard extends Backbone.Model
  sync: (method, model, options) ->
    if method is "read"
      cardDAO = new app.dao.CardDAO(app.db)
      cardDAO.findById parseInt(this.id), (data) ->
        options.success data