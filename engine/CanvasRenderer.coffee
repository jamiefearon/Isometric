
class CanvasRenderer

  constructor: ->
    
    @canvas = document.createElement 'canvas'
    $('#container').append @canvas
    $('#container canvas')[0].id = 'canvas'
    @context = @canvas.getContext "2d"
    


  clear: (colour) =>
    
    @context.fillStyle = colour
    @context.fillRect 0, 0, @canvas.width, @canvas.height
    


  setSize: (width, height) =>
    
    @canvas.width = width
    @canvas.height = height



  # automaticaly change canvas size to screen size 
  fixSizeToScreen: =>
    # TODO - maintain aspect ratio
    window.addEventListener('resize', @resizeCanvas, false)
    @resizeCanvas()

  resizeCanvas: =>
    @setSize(window.innerWidth, window.innerHeight)
    
    
# In the future try to get the drawing(render) function in here
# that way, it will be easier to create a webgl renderer as well