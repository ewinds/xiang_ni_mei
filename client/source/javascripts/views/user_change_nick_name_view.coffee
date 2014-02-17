class app.views.UserChangeNickNameView extends Backbone.View
  events:
    'tap .back-button': 'back'
    'tap .save-button': 'save'
    "keyup input[name='nick_name']": 'observeInput'

  bindings:
    'value input[name="nick_name"]': 'nick_name'

  render: ->
    @$el.html @template(@model.attributes)
    @bindModel()
    this

  back: (event)->
    event.preventDefault()
    window.history.back()

  save: (event)->
    event.preventDefault()
    $('.ui-loader').show()
    @model.save @model.attributes,
      success: $.proxy(@onSuccess, this),
      error: $.proxy(@onFail, this)

  onSuccess: (data)->
    window.localStorage.setItem 'nick_name', data.get 'nick_name'

    $('.ui-loader').hide()
    app.utils.toast.showShort '修改成功'
    window.location.hash = 'users/' + data.id

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
    nickNameVal = @$("input[name='nick_name']").val()
    if nickNameVal isnt '' and saveButton.hasClass('is-disabled')
      saveButton.removeClass 'is-disabled'
    else if nickNameVal is '' and not saveButton.hasClass('is-disabled')
      saveButton.addClass 'is-disabled'