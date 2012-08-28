
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
    @buildingSprites = new Array()
    
    
    # Produce the building sprites from the spritesheet
    for i in [0..@numberOfBuildings - 1]
      # create the building sprite
      buildingSprite = new Sprite(spritesheet: @spritesheet, width: @tileWidth, height: @tileHeight, offsetX: 0, offsetY: i*@tileHeight, frames: @framesPerBuilding[i], duration: @durationPerBuilding[i])
      @buildingSprites.push(buildingSprite)
      
      
  

  # Returns a building sprite based on line number in sprite sheet
  # if firstFrameImage is true then only an img of the first frame
  # is returned this is useful for representing the sprite in a toolbar etc
  getBuildingSprite: (lineNumber) =>
    return @buildingSprites[lineNumber]
    
                                            
    