
class Game extends IsoGame

  constructor: ->
    super
    
    # create renderer
    @createRenderer('canvas')
    @renderer.fixSizeToScreen()
    
    # display tech stats
    @displayTech(true)
    
    grass = new Sprite(src: assetManager.getAsset('image/grass.png'))
    @grid = new IsometricGrid(width: 200, height: 200, defaultTile: grass)
    
    
    @animloop()


  animloop: =>
    super
    
    @renderer.clear('#FFFFFF')
    
    @grid.draw()
    
    # Call @displayFps() at the end of animloop to acuatly calculate the Fps
    @displayFps()
 

  
   
    
    