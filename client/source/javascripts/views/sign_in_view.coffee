class app.views.SignInView extends Backbone.View
  initialize: ->
    @auth_token = window.localStorage.getItem 'auth_token'

  events:
    "tap .back-button": "back"
    "tap .signin-button": "sign_in"
    "keyup input[name='user_name']": 'observeInput'
    "keyup input[name='password']": 'observeInput'

  bindings:
    'value input[name="user_name"]': 'user_name'
    'value input[name="password"]': 'password'

  render: ->
    @$el.html @template()
    @bindModel()
    this

  back: (event)->
    event.preventDefault()
    window.history.back();

  sign_in: (event)->
    event.preventDefault()
    $('.ui-loader').show()
    @model.save @model.attributes,
      success: $.proxy(@onSuccess, this),
      error: $.proxy(@onFail, this)

  onSuccess: (data)->
    user_id = data.get('id')
    user_name = data.get('user_name')
    nick_name = data.get('nick_name')
    access_token = data.get('access_token')
    window.localStorage.setItem 'user_id', user_id
    window.localStorage.setItem 'user_name', user_name
    window.localStorage.setItem 'nick_name', nick_name
    window.localStorage.setItem 'auth_token', access_token

    $('.ui-loader').hide()
    sign_in_callback = window.localStorage.getItem 'sign_in_callback'
    if sign_in_callback
      window.localStorage.removeItem 'sign_in_callback'
      window.location.hash = sign_in_callback
    else
      window.location.hash = 'home'

  onFail: (model, response)->
    $('.ui-loader').hide()
    if response.status is 401
      console?.log "#{response.status} Invalid user name or passoword."
      app.utils.toast.showShort '用户名、密码错误'
    else
      console?.log "#{response.status} requested data not found."
      app.utils.toast.showShort '获取数据失败，请稍后再试'

  observeInput: ->
    signInButton = @$('.signin-button')
    userNameVal = @$("input[name='user_name']").val()
    passwordVal = @$("input[name='password']").val()
    if userNameVal isnt '' and passwordVal isnt '' and signInButton.hasClass('is-disabled')
      signInButton.removeClass 'is-disabled'
    else if (userNameVal is '' or passwordVal is '') and not signInButton.hasClass('is-disabled')
      signInButton.addClass 'is-disabled'