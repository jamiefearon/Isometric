class Building

  constructor: (@sprite, @width, @height, @id, @drawWidth, @drawHeight, @row, @col, @z) -> 


# NOTE: ro and col is the position of the building not the buildingporstion
class BuildingPortion 
  
  constructor: (@building, @row, @col, @z) ->
    # row and col isthe row and col of the Building
    @sprite = @building.sprite
    
