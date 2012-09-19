
class Game extends IsoGame

  constructor: (numberRows, numberCols, tile) ->
    super
    
    # create renderer
    @createRenderer('canvas')
    @renderer.fixSizeToScreen()
    
    # display tech stats
    @displayTech(true)
    
    # display the toolbar
    $("#toolbar").css("visibility","visible")
    
    #create the UI listner
    @UI = new UI()
    
    defaultTile = new Sprite(spritesheet: assetManager.getAsset(tile))
    @grid = new IsometricGrid(width: numberRows, height: numberCols, defaultTile: defaultTile)
    
    @animloop()


  animloop: =>
    super
    
    @renderer.clear('#FFFFFF')
    
    @grid.draw()
    
    # Call @displayFps() at the end of animloop to acuatly calculate the Fps
    @displayFps()
 

  
   
    
    