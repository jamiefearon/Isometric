
class Game extends IsoGame

  constructor: ->
    super
    
    # create renderer
    @createRenderer('canvas')
    @renderer.fixSizeToScreen()
    
   
    grass = new Sprite(spritesheet: assetManager.getAsset('../images/grass.png'))
    @grid = new IsometricGrid(width: 200, height: 200, defaultTile: grass)
    
    
    @animloop()


  animloop: =>
    super
    
    @renderer.clear('#FFFFFF')
    
    @grid.draw()
    
    # Call @displayFps() at the end of animloop to acuatly calculate the Fps
    @displayFps()
 

  
   
    
    