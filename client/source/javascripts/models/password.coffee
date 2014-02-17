class app.models.Password extends Backbone.Model
  url: app.baseUrl + 'api/password/update.json'

  defaults:
    'current_password': ''
    'password': ''
    'password_confirmation': ''

  validate: (attrs, options)->
    if attrs.password isnt attrs.password_confirmation
      '密码与确认值不匹配'
