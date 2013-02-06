#
#
#     Isometric grid - Create an istance of this to use as an isometric grid
#
#

class IsometricGrid

  @renderer = null

  constructor: (parameters) ->
    
    # Tile map matrix - contains all the information for the map TODO - this can be passed as a parameter if one already exists
    @tileMap = parameters.tileMap ? []
    
    # Grid dimentions
    @width = parameters.width ? 4
    @height = parameters.height ? 4
    
    # On any empty tile is draw the default tile
    @defaultTile = parameters.defaultTile ? null
    
    # Calculate tile width and height from defaultTile, if not null
    if @defaultTile isnt null
      @tileWidth = @defaultTile.width
      @tileHeight = @defaultTile.height
      
    # Scroll position
    @scrollPosition =
      x: 0
      y: 0
    
    # Zoom level
    @zoom = 1

    # Default zoom level
    @tileWidth = @defaultTile.width * @zoom
    @tileHeight = @defaultTile.height * @zoom

    # Initially center the starting point horizontally and vertically
    @scrollPosition.y -= @height * @zoom + @scrollPosition.y
    @scrollPosition.x -= @width * @zoom + @scrollPosition.x

    # Tile the mouse is currently hovering above
    @mouseOverTile = null
      
    @dragHelper = 
      active: false
      x: 0
      y: 0
      
    @Keys =
      UP: 38
      DOWN: 40
      LEFT: 37
      RIGHT: 39
      W: 87
      A: 65
      S: 83
      D: 68
      Z: 90,
      X: 88,
      R: 82


    
    
    # TODO fix later
    window.addEventListener 'keydown', (e) =>
      @handleKeyDown(e)
    , false
    
    window.addEventListener 'mousedown', (e) =>
      if e.target.id is 'canvas' then @handleMouseDown(e)
    , false
    
    window.addEventListener 'mousemove', (e) =>
      if e.target.id is 'canvas' then @handleDrag(e)
    , false
    
    window.addEventListener 'mouseup', (e) =>
      if e.target.id is 'canvas' then @handleMouseUp(e)
    , false


  translatePixelsToMatrix: (x, y) ->

    gridOffsetY = @height * @zoom + @scrollPosition.y
    gridOffsetX = @width * @zoom

    # By default the grid appears centered horizontally
    gridOffsetX += (IsometricGrid.renderer.canvas.width / 2) - (@tileWidth * @zoom / 2) + @scrollPosition.x

    col = (2 * (y - gridOffsetY) - x + gridOffsetX) / 2
    row = x + col - gridOffsetX - @tileHeight

    col = Math.round(col / @tileHeight)
    row = Math.round(row / @tileHeight)
    
    return {} =
      row: row
      col: col

  
  # Set zoom level
  setZoom: (value) =>
    @zoom = value

    @tileWidth = @defaultTile.width * @zoom
    @tileHeight = @defaultTile.height * @zoom


  draw: ->
    
    pos_TL = @translatePixelsToMatrix 1, 1
    pos_BL = @translatePixelsToMatrix 1, IsometricGrid.renderer.canvas.height
    pos_TR = @translatePixelsToMatrix IsometricGrid.renderer.canvas.width, 1
    pos_BR = @translatePixelsToMatrix IsometricGrid.renderer.canvas.width, IsometricGrid.renderer.canvas.height
    
    startRow = pos_TL.row
    startCol = pos_TR.col
    rowCount = pos_BR.row + 1
    colCount = pos_BL.col + 1
    
    if startRow < 0 then startRow = 0
    if startCol < 0 then startCol = 0
    if rowCount > @width then rowCount = @width
    if colCount > @height then colCount = @height

    
    # Display visible row and col count if settings allow
    if IsoGame.settings.techStats
      $("#rowStart").html(startRow)
      $("#colStart").html(startRow)
      $("#rowEnd").html(rowCount)
      $("#colEnd").html(colCount)
      if @mouseOverTile isnt null
        $("#arraySize").html(@mouseOverTile.buildings.length)
        if @mouseOverTile.tilePropeties.occupied
          $("#occupied").html('true')
        else
          $("#occupied").html('false') 
      else
        $("#arraySize").html('')
        $("#occupied").html('')
   
    for row in [startRow..rowCount - 1]
      for col in [startCol..colCount - 1]
        xpos = (row - col) * @tileHeight + (@width * @zoom)
        xpos += (IsometricGrid.renderer.canvas.width / 2) - (@tileWidth / 2 * @zoom) + @scrollPosition.x
        ypos = (row + col) * (@tileHeight / 2) + (@height * @zoom) + @scrollPosition.y

        # save these positions to use later to draw the clip dimond
        startX = xpos
        startY = ypos
        
        if (Math.round(xpos) + @tileWidth >= 0 and Math.round(ypos) + @tileHeight >= 0 && Math.round(xpos) <= IsometricGrid.renderer.canvas.width && Math.round(ypos) <= IsometricGrid.renderer.canvas.height)
          
          # Draw the defaultTile
          IsometricGrid.renderer.context.drawImage(@defaultTile.spritesheet, Math.round(xpos), Math.round(ypos), @tileWidth, @tileHeight)
         
          # Draw a building 
          if (typeof @tileMap[row] isnt 'undefined' and typeof @tileMap[row][col] isnt 'undefined')
            if @isArray(@tileMap[row][col].buildings)
              # set the starting position of the clip at the bottom most moved by section amount
              startX += @tileWidth * 0.5 
              startY += @tileHeight
              for i in [0..@tileMap[row][col].buildings.length - 1]  # loop through each item in the tile and draw it (should already be z ordered)
               
                buildingPosition = @getBuildingLocation(@tileMap[row][col].buildings[i]) 
                @tileMap[row][col].buildings[i].sprite.setPosition(buildingPosition.x, buildingPosition.y)
              
                IsometricGrid.renderer.context.save()
                IsometricGrid.renderer.context.strokeStyle = "transparent"
                IsometricGrid.renderer.context.beginPath()
                IsometricGrid.renderer.context.moveTo(Math.round(startX),Math.round(startY))
                IsometricGrid.renderer.context.lineTo(Math.round(startX) + 0.5 * @tileWidth, Math.round(startY) - 0.5 * @tileHeight)
                IsometricGrid.renderer.context.lineTo(Math.round(startX), Math.round(startY) - @tileHeight)
                IsometricGrid.renderer.context.lineTo(Math.round(startX) - 0.5 * @tileWidth, Math.round(startY) - 0.5 * @tileHeight)
                IsometricGrid.renderer.context.lineTo(Math.round(startX), Math.round(startY)) 
                IsometricGrid.renderer.context.stroke()
                IsometricGrid.renderer.context.clip()
              
                #if @tileMap[row][col][i].sprite.duration is 0
                @tileMap[row][col].buildings[i].sprite.draw() #if meow == 2
                #else
                #  @tileMap[row][col][i].sprite.animate()
              
                IsometricGrid.renderer.context.restore()
              
              


  # Returns the position of where a building is located
  getBuildingLocation: (building) =>
    xpos = (building.row - building.col) * @tileHeight + (@width * @zoom)
    xpos += (IsometricGrid.renderer.canvas.width / 2) - (@tileWidth / 2 * @zoom) + @scrollPosition.x
    ypos = (building.row + building.col) * (@tileHeight / 2) + (@height * @zoom) + @scrollPosition.y
    ypos -= (building.sprite.height * @zoom) - (@tileHeight)
    xpos -= ((building.sprite.width * @zoom) / 2) - (@tileWidth / 2) 
    return {x: xpos , y: ypos}

         
   
  # Puts a new building into the grid at postion x,y
  placeBuilding: (x, y, data) =>
    pos = @translatePixelsToMatrix(x, y)
    # create the sprite
    sprite = new Sprite(spritesheet: data.spritesheet, width: data.pixelWidth, height: data.pixelHeight, offsetX: data.offsetX, offsetY: data.offsetY, frames: data.frames, duration: data.duration)
    # create the building from the sprite
    obj = new Building(sprite, data.width, data.height, data.id, data.drawWidth, data.drawHeight)

    if @checkIfTileIsFree(obj, pos.row, pos.col)
      for i in [(pos.row + 1) - obj.drawWidth..pos.row] 
        for j in [(pos.col + 1) - obj.drawHeight..pos.col]
          if (@tileMap[i] == undefined) then @tileMap[i] = []
          if (i is pos.row and j is pos.col)  # This will be the bottom corner of the building where the actual building will be placed
            if @tileMap[i][j] is undefined then @tileMap[i][j] = {buildings : [], tilePropeties : {} }
            obj.row = i
            obj.col = j
            obj.z = i + j
            @tileMap[i][j].buildings.push(obj)
            @tileMap[i][j].buildings.sort(@sortZ)
            @tileMap[i][j].tilePropeties["occupied"] = true
          else  # Place a building portion here, a reference to the actual building
            if @tileMap[i][j] is undefined then @tileMap[i][j] = {buildings : [], tilePropeties : {} }
            @tileMap[i][j].buildings.push(new BuildingPortion(obj, pos.row, pos.col, pos.col + pos.row))
            @tileMap[i][j].buildings.sort(@sortZ)
            @tileMap[i][j].tilePropeties["occupied"] = true if Math.abs(i - pos.row) < obj.height && Math.abs(j - pos.col) < obj.width




  # Returns true if a tile is free to be build on, otherwise returns false
  checkIfTileIsFree: (obj, row, col) =>
    
    for i in [(row + 1) - obj.width..row]
      for j in [(col + 1) - obj.height..col]
        if (@tileMap[i] != undefined and @tileMap[i][j] != undefined)
          return false if @tileMap[i][j].tilePropeties.occupied == true
    return true

       
  # TODO - fix later  
  handleKeyDown: (e) =>
    switch e.keyCode
      when @Keys.UP, @Keys.W
        @scrollPosition.y -= 20
      when @Keys.DOWN, @Keys.S
        @scrollPosition.y += 20
      when @Keys.LEFT, @Keys.A 
        @scrollPosition.x -= 20
      when @Keys.RIGHT, @Keys.D
        @scrollPosition.x += 20
    
   
   
  handleDrag: (e) =>
    e.preventDefault()
    if @dragHelper.active
      x = e.clientX
      y = e.clientY
      @scrollPosition.x = Math.round((x - @dragHelper.x))
      @scrollPosition.y = Math.round((y - @dragHelper.y))
    else # mouse is not dragging just moving
      # Set mouseOverTile to the current tile
      tile = @translatePixelsToMatrix(e.clientX, e.clientY)
      if (typeof @tileMap[tile.row] isnt 'undefined' and typeof @tileMap[tile.row][tile.col] isnt 'undefined')
        @mouseOverTile = @tileMap[tile.row][tile.col]

  handleMouseUp: (e) =>
    e.preventDefault()
    @dragHelper.active = false
    
  handleMouseDown: (e) =>
      e.preventDefault()
      x = e.clientX
      y = e.clientY
      @dragHelper.active = true
      @dragHelper.x = x - @scrollPosition.x  
      @dragHelper.y = y - @scrollPosition.y
     
  # returns true if an object is an array
  isArray: (obj) =>
    return Object.prototype.toString.call(obj) is '[object Array]'

  # sorts an array based on the z values of its members
  sortZ: (a, b) =>
    if (a.z < b.z)
      return -1
    if (a.z > b.z)
      return 1
    return 0
        
        
        
        
        
        
        
        
        
        
        
        
    