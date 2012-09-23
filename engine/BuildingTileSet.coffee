class BuildingTileSet


  constructor: (@spritesheet)  ->
    
    # an array containing all building data to recreate a building
    @buildings = new Array()
      

  # Returns a building data based on line number in sprite sheet
  getBuilding: (lineNumber) =>
    return @buildings[lineNumber]
    
                                            
    