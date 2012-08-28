
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
    
    
    # TODO - HAVE A USER DATA OBJECT IN HERE WHICH WILL CONTAIN ALL INFORMATION TO REMAKE MAP SUCH AS:
    # RAW IMAGES THE ASSET MANAGER WILL NEED TO DOWNLOAD TO CREATE THE BELOW
    # AN ARRAY OF BUILDING_TILE_SETS (ALREADING CONTANS SPRITESHEET)
    # AN ARRAY OF BUILDINGS (SPRITE COMESFROM BUILDING_TILE_SET , ALSO CONTAINS BUILDING INFO)
    # THE GRID (MAP)
    # THIS OBJECT WILL THEN BE TURNED INTO JASON TO BE SAVED
    
    
    

    # TEST!!!!!!!!!!!!
    @buildingTileSet = new BuildingTileSet(assetManager.getAsset('sprite1'), 60, 60, 5, [2,3,4,5,1], [1000,2000,3000,2000,0])
    
    @building1 = @buildingTileSet.getBuildingSprite(0)
    @building2 = @buildingTileSet.getBuildingSprite(1)
    @building3 = @buildingTileSet.getBuildingSprite(2)
    @building4 = @buildingTileSet.getBuildingSprite(3)
    @building5 = @buildingTileSet.getBuildingSprite(4)
    
    @building1.setPosition(20,20)
    @building2.setPosition(40,80)
    @building3.setPosition(50,120)
    @building4.setPosition(60,260)
    @building5.setPosition(70,370)
   
    
    
    @animloop()


  animloop: =>
    super
    
    @renderer.clear('#FFFFFF')
    
    @grid.draw()
    
    @building1.animate()
    @building2.animate()
    @building3.animate()
    @building4.animate()
    @building5.animate()
    
    
    # Call @displayFps() at the end of animloop to acuatly calculate the Fps
    @displayFps()
 

  
   
    
    