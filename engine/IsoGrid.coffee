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
      
  
  # set zoom level
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
    
    for row in [startRow..rowCount - 1]
      for col in [startCol..colCount - 1]
        xpos = (row - col) * @tileHeight + (@width * @zoom)
        xpos += (IsometricGrid.renderer.canvas.width / 2) - (@tileWidth / 2 * @zoom) + @scrollPosition.x
        ypos = (row + col) * (@tileHeight / 2) + (@height * @zoom) + @scrollPosition.y
        
        if (Math.round(xpos) + @tileWidth >= 0 and Math.round(ypos) + @tileHeight >= 0 && Math.round(xpos) <= IsometricGrid.renderer.canvas.width && Math.round(ypos) <= IsometricGrid.renderer.canvas.height)
          IsometricGrid.renderer.context.drawImage(@defaultTile.spritesheet, Math.round(xpos), Math.round(ypos), @tileWidth, @tileHeight)
          if (typeof @tileMap[row] isnt 'undefined' and typeof @tileMap[row][col] isnt 'undefined')
            if (@tileMap[row][col] instanceof Building)
              ypos -= (@tileMap[row][col].sprite.height * @zoom) - (@tileHeight)  
              xpos -= ((@tileMap[row][col].sprite.width * @zoom) / 2) - (@tileWidth / 2) 
              @tileMap[row][col].sprite.setPosition(xpos, ypos)
              if @tileMap[row][col].sprite.duration is 0
                @tileMap[row][col].sprite.draw()
              else
                @tileMap[row][col].sprite.animate()
         
   
  # Puts a new building into the grid at postion x,y
  placeBuilding: (x, y, data) =>
    pos = @translatePixelsToMatrix(x, y)
    # create the sprite
    sprite = new Sprite(spritesheet: data.spritesheet, width: data.pixelWidth, height: data.pixelHeight, offsetX: data.offsetX, offsetY: data.offsetY, frames: data.frames, duration: data.duration)
    # create the building from the sprite
    obj = new Building(sprite, data.width, data.height, data.id)

    for i in [(pos.row + 1) - obj.width..pos.row]
      for j in [(pos.col + 1) - obj.height..pos.col]
        if (@tileMap[i] == undefined) then @tileMap[i] = []
        if (i is pos.row and j is pos.col) then @tileMap[i][j] = obj


       
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
     

        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
    