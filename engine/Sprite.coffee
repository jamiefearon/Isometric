
class Sprite

  # tell Sprite which renderer to use
  @renderer = null

  constructor: (parameters) ->
    
    # spritesheet can be a spritesheet or a single image
    @spritesheet = parameters.spritesheet ? console.log('ERROR - no spritesheet selected')
    
    @posX = parameters.x ? 0
    @posY = parameters.y ? 0
    @width = parameters.width ? @spritesheet.width     # if width or height not given then assume sprite 
    @height = parameters.height ? @spritesheet.height  # image is whole image and not a spritesheet
    @offsetX =  parameters.offsetX ? 0
    @offsetY = parameters.offsetY ? 0
    @frames = parameters.frames ? 0
    @duration = parameters.duration ? 0 
    
    @currentFrame = 0
    
    @currentTime = (new Date()).getTime()
    @ftime = @currentTime + (@duration / @frames)
   
    
  
  setPosition: (x, y) =>
    @posX = x
    @posY = y
    
       
  animate: =>
   
    if @currentTime > @ftime then @nextFrame()
    
    # Update time and draw
    @currentTime = (new Date()).getTime()
    @draw()
    
    
  nextFrame: =>
    
    if @duration > 0
      d = new Date()
      @ftime = d.getTime() + (@duration / @frames)
      
      @offsetX = @width * @currentFrame
      
      if @currentFrame is @frames - 1
        @currentFrame = 0
      else
        @currentFrame++


  draw: =>
    Sprite.renderer.context.drawImage(@spritesheet, @offsetX, @offsetY, @width, @height, @posX, @posY, @width, @height)
    # TODO - pass to the renderer draw(render) function renderer.draw(image)
      
     
  # returns an image representation of the sprite, ie the first frame; this is useful for representing the sprite in a toolbar etc
  getTumbnail: => 
      
      
      