
#
# BuildingTileSet contains a spritesheet and returns building sprites based on this. 
# It does not contain any builidng logic
#

###

Each spritesheet should look like this:

-----------------------------------------------------------------------------------------------
building 1 (frame 1)
-----------------------------------------------------------------------------------------------
building 2 (frame 1)  -  building 2 (frame 2)  -  building 2 (frame 3) 
-----------------------------------------------------------------------------------------------
building 3 (frame 1)  -  building 3 (frame 2) 
-----------------------------------------------------------------------------------------------
building 4 (frame 1)  -  building 4 (frame 2)  -  building 4 (frame 3)  -  building 4 (frame 4)
-----------------------------------------------------------------------------------------------


@framesPerBuilding contains an array storing information about how many frames each building has.

Usage, assuming above spritesheet is used:

framesPerBuilding = [1, 3, 2, 4]

###



class BuildingTileSet


  constructor: (@spritesheet, @tileWidth, @tileHeight, @numberOfBuildings, @framesPerBuilding, @durationPerBuilding)  ->
    
    # an array containing all building sprites
    # TODO: remove this and change to an array of buildings
    @buildings = new Array()
    
    
    # Produce the building sprites from the spritesheet
    for i in [0..@numberOfBuildings - 1]
      # create the building sprite
      buildingSprite = new Sprite(spritesheet: @spritesheet, width: @tileWidth, height: @tileHeight, offsetX: 0, offsetY: i*@tileHeight, frames: @framesPerBuilding[i], duration: @durationPerBuilding[i])
      # create a building and put a sprite in
      building = new Building(new Sprite(buildingSprite, 1, 1)) # TODO - this is wrong!!!
      @buildings.push(buildingSprite)
      
      
  

  # Returns a building based on line number in sprite sheet
  getBuilding: (lineNumber) =>
    return @buildings[lineNumber]
    
                                            
    