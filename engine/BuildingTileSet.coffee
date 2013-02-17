# Change this to store the refrence to the spritesheets i.e. spritesheets/trees.png
# And store the Jason from Texturepacker that has also been modified by BuildingSetCreationDialog


class BuildingTileSet


  constructor: (@spritesheet)  ->
    
    # an array containing all building data to recreate a building
    @buildings = new Array()
      

  # Returns a building data based on line number in sprite sheet
  getBuilding: (lineNumber) =>
    return @buildings[lineNumber]
    
                                            
    