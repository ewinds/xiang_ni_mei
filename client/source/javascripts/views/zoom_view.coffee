app.views.ZoomView = (container, element, overlayer) ->
  overlayer = $(overlayer).hammer(
    prevent_default: true
    drag_min_distance: 0
  )

  @element = $(element)
  @MIN_ZOOM = 1
  @MAX_ZOOM = 3
  @scaleFactor = 1
  @previousScaleFactor = 1

  @cssOrigin = ""
  self = this
  overlayer.bind "transformstart", (event) ->
    e = event
    tch1 = [e.gesture.touches[0].pageX, e.gesture.touches[0].pageY]
    tch2 = [e.gesture.touches[1].pageX, e.gesture.touches[1].pageY]

    tcX = (tch1[0] + tch2[0]) / 2
    tcY = (tch1[1] + tch2[1]) / 2

    toX = tcX
    toY = tcY
    left = $(self.element).offset().left
    top = $(self.element).offset().top
    self.cssOrigin = (-(left) + toX) / self.scaleFactor + "px " + (-(top) + toY) / self.scaleFactor + "px"

  overlayer.bind "transform", (event) ->
    self.scaleFactor = self.previousScaleFactor * event.gesture.scale
    self.scaleFactor = Math.max(self.MIN_ZOOM, Math.min(self.scaleFactor, self.MAX_ZOOM))
    self.transform event

  overlayer.bind "transformend", (event) ->
    self.previousScaleFactor = self.scaleFactor

  dragview = new app.views.DragView($(container))
  overlayer.bind "dragstart", $.proxy(dragview.OnDragStart, dragview)
  overlayer.bind "drag", $.proxy(dragview.OnDrag, dragview)
  overlayer.bind "dragend", $.proxy(dragview.OnDragEnd, dragview)
  setInterval $.proxy(dragview.WatchDrag, dragview), 10

  @transform = (e) ->
    #We're going to scale the X and Y coordinates by the same amount
    cssScale = "scale3d(" + self.scaleFactor + ", " + self.scaleFactor + ", 1) rotate3d(0, 0, 1, " + e.gesture.rotation + "deg)"
    self.element.css
      '-webkit-transform': cssScale
      '-webkit-transform-origin': self.cssOrigin

  this
