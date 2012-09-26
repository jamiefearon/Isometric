class UI

  constructor: (parameters) ->
    
    # set the action of the left mouse button on the toolbar
    window.addEventListener 'mousedown', (e) =>
      button = e.which or e.button
      if button == 1 then @UIMouseDown(e) # Left mouse click
    , false
    
    # @toolSelect contains a string representing the selected tool
    @toolSelect = null

    @selectedBuilding = null

    # Current's zoom level
    @zoomLevel = 1;
    
    
    # @buildingSelectionToolBarVisible equals the number of the flag if selected, else false
    @buildingSelectionToolBarVisible = false;
    
    
    # create the toolbar
    @setupToolbar()
    
    
    
  # 
  #  Creates the fixed buttons of the toolbar
  #
  
  setupToolbar: =>
   
    $("#toolbar ul").append('<li id="zoomIn"></li>')
    $('#zoomIn').css('background',  'url(image/zoomin.png) no-repeat')
    
    
    $("#toolbar ul").append('<li id="zoomOut"></li>')
    $('#zoomOut').css('background',  'url(image/zoomout.png) no-repeat')
    
    
    $("#toolbar ul").append('<li id="demolish"></li>')
    $('#demolish').css('background',  'url(image/delete.png) no-repeat')
    
    
    # The flag icons which the user can load a icon-set into
    for flag in [1..5]
      # create flag icon
      $("#toolbar ul").append("<li id='iconSet#{flag}'></li>")
      $("#iconSet#{flag}").css("background",  "url(image/flag#{flag}.png) no-repeat")
      # attach the setBuildingTileSet right click context menu to it
      $("#iconSet#{flag}").rightClick (e) =>
        @displayBuildingSelectonDialog(e.target.id)
      




  #
  # Brings up the Building Selection dialog from right click on flags
  #
  
  displayBuildingSelectonDialog: (id) =>
    # make the setBuildingTileSet dialog visible
    $("#setBuildingTileSet").css("visibility","visible")

    flagNumber = id.substring(7,id.length)
    buildingTileSet = undefined

    $("#done").unbind("click").click =>
      $("#setBuildingTileSet").css("visibility","hidden")

      if mapData.buildingTileSets is undefined
        mapData.buildingTileSets = new Array()
        mapData.buildingTileSets[flagNumber] = buildingTileSet
      else
        mapData.buildingTileSets[flagNumber] = buildingTileSet
      
    $("#createbuilding").unbind("click").click =>
      
      # get all the necessary variables from the user
      tSpritesheet = assetManager.getAsset($("#buildingTileSetName").val())
      tOffsetX = parseInt($("#offsetX").val())
      tOffsetY = parseInt($("#offsetY").val())
      tPixelWidth = parseInt($("#pixeltileWidth").val())
      tPixelHeight = parseInt($("#pixeltileHeight").val())
      tWidth = parseInt($("#tileWidth").val())
      tHeight = parseInt($("#tileHeight").val())
      tFrames = parseInt($("#frames").val())
      tDuration = parseInt($("#duration").val())
      tId = parseInt($("#id").val())

      # create BuildingTileSet if one has not yet been created 
      # TODO - make this logic more elegant
      if mapData.buildingTileSets isnt undefined and buildingTileSet is undefined
        buildingTileSet = mapData.buildingTileSets[flagNumber] ? new BuildingTileSet(tSpritesheet)
      else if buildingTileSet is undefined
        buildingTileSet = new BuildingTileSet(tSpritesheet)

      # create an object to hold all the data needed to receate the building and its sprite
      data = {
        spritesheet: tSpritesheet,
        pixelWidth: tPixelWidth,
        pixelHeight: tPixelHeight,
        offsetX: tOffsetX,
        offsetY: tOffsetY,
        frames: tFrames,
        duration: tDuration,
        width: tWidth,
        height: tHeight,
        id: tId
      };
  
      # push building into buildingTileset
      buildingTileSet.buildings.push(data)
    
    
  
  #
  #  put the correct BULIING_TILESET thumnails into build toolbar
  #
  
  loadBuildingData: (flagNumber) =>
    # get the buildingTileSet from mapData, if it doesn't exist just return
    if mapData.buildingTileSets isnt undefined and mapData.buildingTileSets[flagNumber] isnt undefined
      buildingTileSet = mapData.buildingTileSets[flagNumber]
    else
      # Clear the toolbar
      $("#buildingSelectionToolbar ul").empty()
      return
    
    # make sure the toolbar is empty from the last load
    $("#buildingSelectionToolbar ul").empty()
    
    # fislty get filename from spritesheet.src (i.e. convert from url to just *****.png)
    spriteMap = mapData.buildingTileSets[flagNumber].spritesheet.src
    index = spriteMap.lastIndexOf("/") + 1
    filename = spriteMap.substr(index)
    
    # now load the icons
    that = this
    for i in [0..mapData.buildingTileSets[flagNumber].buildings.length - 1]
      $("#buildingSelectionToolbar ul").append("<li id='buildingIcon#{i}' class='#{flagNumber}' data-iconNumber='#{i}' data-flagNumber='#{flagNumber}'></li>")
      $("#buildingIcon#{i}").css("background", "url(image/#{filename}) -#{mapData.buildingTileSets[flagNumber].buildings[i].offsetX}px -#{mapData.buildingTileSets[flagNumber].buildings[i].offsetY}px no-repeat")
      $("#buildingIcon#{i}").click (e) ->
        that.selectedBuilding = mapData.buildingTileSets[parseInt($(this).attr("data-flagNumber"))].buildings[parseInt($(this).attr("data-iconNumber"))]
      # resize any relevent css values of li and buildingSelectionToolbar TODO FIX THIS GODDAMMIT!!!!
      $("#buildingSelectionToolbar li").css('width', "#{mapData.buildingTileSets[flagNumber].buildings[i].pixelWidth}px")
      $("#buildingSelectionToolbar li").css('height', "#{mapData.buildingTileSets[flagNumber].buildings[i].pixelHeight}px")
      $("#buildingSelectionToolbar").css('height', "#{mapData.buildingTileSets[flagNumber].buildings[i].pixelHeight}px")
  
    
    
  # 
  #  Listen for button clicks on UI
  # 
   
  UIMouseDown: (e) =>
    x = e.clientX
    y = e.clientY

    # the id of the clicked on element
    idClickEle = e.target.getAttribute('id')
    
    # if the element clicked is canvas
    if idClickEle is 'canvas'

      # place building
      if @selectedBuilding isnt null
        console.log('sel bil = ' + @selectedBuilding.width)
        game.grid.placeBuilding(x, y, @selectedBuilding)
    
    
    # detect if an icon-set has been clicked on
    if idClickEle.indexOf("iconSet") != -1
      
      if @buildingSelectionToolBarVisible == false
        
        # set @buildToolBarVisible to the number of the build tool
        @buildingSelectionToolBarVisible = idClickEle.substring(7,idClickEle.length)
        @toolSelect = 'build'
        
        # make the build toolbar visible
        $("#buildingSelectionToolbar").css("visibility","visible")
        
        # load tilesets into toolbar
        @loadBuildingData(@buildingSelectionToolBarVisible)
          
      else
        
        # if the user has clicked on a flag which is already open then close it
        if @buildingSelectionToolBarVisible == idClickEle.substring(7,idClickEle.length)
          $("#buildingSelectionToolbar").css("visibility","hidden")
          $("#buildingSelectionToolbar ul").empty()
          @buildingSelectionToolBarVisible = false
          @toolSelect = null
        else # close the current one and open the new selected one
          @buildingSelectionToolBarVisible = idClickEle.substring(7,idClickEle.length)
          @loadBuildingData(@buildingSelectionToolBarVisible)
    
    # detect if other icons are selected
    switch idClickEle
      
      when 'zoomIn'
        @toolSelect = 'zoomIn'
        @zoomLevel = @zoomLevel * 2
        @zoomLevel
        game.grid.setZoom(@zoomLevel)
        
      when 'zoomOut'
        @toolSelect = 'zoomOut'
        @zoomLevel= @zoomLevel / 2
        game.grid.setZoom(@zoomLevel)
