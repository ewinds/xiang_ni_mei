class app.routers.AppRouter extends Backbone.Router
# The Router constructor
  initialize: ->
    app.slider = new PageSlider($('body'));
    Backbone.hammerOptions =
      prevent_default: true
      tap: true

  # Backbone.js Routes
  routes:
  # When there is no hash bang on the url, the home method is called
    '': 'home'
    'home': 'home'
    'settings': 'settings'
    'collections/:id': 'collection'
    'topics/:id': 'topic'
    'topics/:id/save': 'save'
    'sign_in': 'sign_in'
    'users/:id': 'show_user'
    'users/:id/edit?:type': 'edit_user'
    'sign_out': 'sign_out'
    'cards': 'cards'
    'cards/:id': 'card'

  # Home method
  home: ->
    # Since the home view never changes, we instantiate it and render it only once
    unless app.homeView
      app.homeView = new app.views.HomeView()
      app.homeView.render()
    else
      console.log "reusing home view"
      app.homeView.delegateEvents()
    # delegate events when the view is recycled
    app.slider.slidePage app.homeView.$el

  settings: ->
    user = new app.models.User()
    user.id = window.localStorage.getItem "user_id"
    app.settingsView = new app.views.SettingsView(model: user)
    app.settingsView.render()
    app.slider.slidePageFrom app.settingsView.$el, "page-left"

  collection: (id)->
    collection = new app.models.Collection(id: id)
    collection.fetch success: (data)->
      app.collectionView = new app.views.CollectionView(model: data)
      app.collectionView.render()
      app.slider.slidePage app.collectionView.$el

  topic: (id)->
    topic = new app.models.Topic(id: id)
    topic.fetch success: (data)->
      app.topicView = new app.views.TopicView(model: data)
      app.topicView.render()
      app.slider.slidePage app.topicView.$el

  save: (id)->
    card = new app.models.Card()
    card.set 'user_id', id
    imageData = window.localStorage.getItem('image_data')
    width =parseInt(window.localStorage.getItem('image_data_width')) * 0.8
    height =parseInt(window.localStorage.getItem('image_data:height')) * 0.8
    app.saveView = new app.views.SaveView
      model: card
      data:
        width: width
        height: height
        imageData: imageData
    app.saveView.render()
    app.slider.slidePage app.saveView.$el

  sign_in: ->
    userSession = new app.models.UserSession()
    app.signInView = new app.views.SignInView(model: userSession)
    app.signInView.render()
    app.slider.slidePage app.signInView.$el

  sign_out: ->
    signOut = new app.models.UserSignOut()
    signOut.fetch
      success: ->
        window.localStorage.removeItem 'user_id'
        window.localStorage.removeItem 'user_name'
        window.localStorage.removeItem 'nick_name'
        window.localStorage.removeItem 'auth_token'
        window.location.hash = 'home'
      error: (model, response)->
        if response.status is 401
          console?.log "#{response.status} Invalid token."
          app.utils.toast.showShort '认证失败,请重新登录'
          window.localStorage.removeItem 'user_id'
          window.localStorage.removeItem 'user_name'
          window.localStorage.removeItem 'nick_name'
          window.localStorage.removeItem 'auth_token'
          window.location.hash = 'sign_in'
        else
          console?.log "#{response.status} requested data not found."
          app.utils.toast.showShort '获取数据失败，请稍后再试'
          $('.ui-loader').hide()
#          window.location.hash = 'home'

  show_user: (id)->
    user = new app.models.User()
    user.id = id
    user.set 'user_name', window.localStorage.getItem('user_name')
    user.set 'nick_name', window.localStorage.getItem('nick_name')
    app.userView = new app.views.UserView(model: user)
    app.userView.render()
    app.slider.slidePage app.userView.$el

  edit_user: (id, type)->
    user = new app.models.User()
    user.id = id
    user.set 'user_name', window.localStorage.getItem('user_name')
    user.set 'nick_name', window.localStorage.getItem('nick_name')
    if type is 'nick_name'
      app.userChangeView = new app.views.UserChangeNickNameView(model: user)
    else
      password = new app.models.Password()
      app.userChangeView = new app.views.UserChangePasswordView(model: password, user: user)
    app.userChangeView.render()
    app.slider.slidePage app.userChangeView.$el

  cards: ->
    user = new app.models.User()
    user_id = window.localStorage.getItem('user_id')
    user.id = if user_id then user_id else '0'

    app.cardsView = new app.views.CardsView(model: user)
    app.cardsView.render()
    app.slider.slidePage app.cardsView.$el

  card: (id)->
    card = new app.models.LocalCard(id: id)
    card.fetch success: (data)->
      app.cardView = new app.views.CardView(model: data)
      app.cardView.render()
      app.slider.slidePage app.cardView.$el