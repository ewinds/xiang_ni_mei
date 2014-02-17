class app.views.UserChangePasswordView extends Backbone.View
  events:
    'tap .back-button': 'back'
    'tap .save-button': 'save'
    "keyup input[name='current_password']": 'observeInput'
    "keyup input[name='password']": 'observeInput'
    "keyup input[name='password_confirmation']": 'observeInput'

  bindings:
    'value input[name="current_password"]': 'current_password'
    'value input[name="password"]': 'password'
    'value input[name="password_confirmation"]': 'password_confirmation'

  render: ->
    @$el.html @template()
    @bindModel()
    this

  back: (event)->
    event.preventDefault()
    window.history.back()

  save: (event)->
    event.preventDefault()
    unless @model.isValid()
      app.utils.toast.showShort @model.validationError
      return
    $('.ui-loader').show()
    @model.save @model.attributes,
      success: $.proxy(@onSuccess, this),
      error: $.proxy(@onFail, this)

  onSuccess: (data)->
    $('.ui-loader').hide()
    app.utils.toast.showShort '修改成功'
    window.location.hash = 'users/' + @options.user.id

  onFail: (model, response)->
    $('.ui-loader').hide()
    if response.status is 401
      console?.log "#{response.status} Invalid token."
      app.utils.toast.showShort '认证失败，请重新登录'
      window.localStorage.setItem 'sign_in_callback', window.location.hash.replace('#', '')
      window.location.hash = 'sign_in'
    else
      console?.log "#{response.status} requested data not found."
      app.utils.toast.showShort '获取数据失败，请稍后再试'

  observeInput: ->
    saveButton = @$('.save-button')
    currentPasswordVal = @$("input[name='current_password']").val()
    passwordVal = @$("input[name='password']").val()
    passwordConfirmVal = @$("input[name='password_confirmation']").val()
    if currentPasswordVal isnt '' and passwordVal isnt '' and passwordConfirmVal isnt '' and saveButton.hasClass('is-disabled')
      saveButton.removeClass 'is-disabled'
    else if (currentPasswordVal is '' or passwordVal is '' or passwordConfirmVal is '') and not saveButton.hasClass('is-disabled')
      saveButton.addClass 'is-disabled'

