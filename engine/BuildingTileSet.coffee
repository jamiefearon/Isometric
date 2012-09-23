class BuildingTileSet


  constructor: (@spritesheet)  ->
    
    # an array containing all building sprites
    # TODO: remove this and change to an array of buildings
    @buildings = new Array()
      

  # Returns a building based on line number in sprite sheet
  getBuilding: (lineNumber) =>
    return @buildings[lineNumber]
    
                                            
    