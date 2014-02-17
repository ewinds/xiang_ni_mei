class app.models.UserSession extends Backbone.Model
  url: app.baseUrl + 'api/sign_in.json'

  defaults:
    'user_name': ''
    'password': ''
  