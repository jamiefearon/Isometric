
class Game extends IsoGame

  constructor: ->
    super
    
    # create renderer
    @createRenderer('canvas')
    @renderer.fixSizeToScreen()
    
    spritesheet = assetManager.getAsset 'sprite1'
    
    @gray = new Sprite(x: 40, y: 60, spritesheet: spritesheet, width: 60, height: 60, offsetX: 0, offsetY: 0, frames: 5, duration: 5000)
    @yellow = new Sprite(x: 80, y: 100, spritesheet: spritesheet, width: 60, height: 60, offsetX: 0, offsetY: 60, frames: 5, duration: 2500)
    @red = new Sprite(x: 120, y: 140, spritesheet: spritesheet, width: 60, height: 60, offsetX: 0, offsetY: 120, frames: 5, duration: 1666)
    @blue = new Sprite(x: 160, y: 180, spritesheet: spritesheet, width: 60, height: 60, offsetX: 0, offsetY: 180, frames: 5, duration: 1250)
    @green = new Sprite(x: 200, y: 220, spritesheet: spritesheet, width: 60, height: 60, offsetX: 0, offsetY: 240, frames: 5, duration: 1000)
    
    @grass = new Sprite(spritesheet: assetManager.getAsset('grass'), x: 300, y: 300)
    
    @animloop()


  animloop: =>
    super
    
    @renderer.clear('#FFFFFF')
    
    # Remember to pass animate in animloop to keep a sprite animated - draw is automatically called from animate
    @gray.animate()
    @yellow.animate()
    @red.animate()
    @blue.animate()
    @green.animate()
    
    # Remember to pass draw in animloop to keep a sprite drawn
    @grass.draw()
    
    # Call @displayFps() at the end of animloop to acuatly calculate the Fps
    @displayFps()
 

  
   
    
    