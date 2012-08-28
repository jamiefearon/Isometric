class UI

  constructor: (parameters) ->
    
    # set the action of the left mouse button on the toolbar
    window.addEventListener 'mousedown', (e) =>
      button = e.which or e.button
      if button == 1 then @UIMouseDown(e) # Left mouse click
    , false
    
    # @toolSelect contains a string representing the selected tool
    @toolSelect = null;
    
    
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
    
    # actions for ok and cancel buttons
   
    $("#cancel").unbind("click").click =>
      $("#setBuildingTileSet").css("visibility","hidden")
      
    $("#ok").unbind("click").click =>
      # get the number of the flag in question
      flagNumber = id.substring(7,id.length)
      
      # get the framesPerBuilding and durationPerBuilding
      
      # convert the comma seperated list into an array then change all elements from strings into integers
      framesPerBuilding = $("#framesPerBuilding").val().split(',')      
      for i in [1..framesPerBuilding]
        framesPerBuilding[i] = +framesPerBuilding[i]
      
      durationPerBuilding = $("#durationPerBuilding").val().split(',')      
      for i in [1..durationPerBuilding]
        durationPerBuilding[i] = +durationPerBuilding[i]
      
      
      # create BuildingTileSet
      buildingTileSet = new BuildingTileSet(assetManager.getAsset($("#buildingTileSetName").val()), $("#tileWidth").val(), $("#tileHeight").val(), $("#numberOfBuildings").val(), framesPerBuilding, durationPerBuilding)
      
      # save the tilemap into mapData
      if mapData.buildingTileSets is undefined
        mapData.buildingTileSets = new Array()
        mapData.buildingTileSets[flagNumber] = buildingTileSet
      else
        mapData.buildingTileSets[flagNumber] = buildingTileSet
        
      # load the building tileset data into the selection toolbar and hide the current dialog
      @loadBuildingData(flagNumber)
      $("#setBuildingTileSet").css("visibility","hidden")
    
    
  
  #
  #  put the correct BULIING_TILESET thumnails into build toolbar
  #
  
  loadBuildingData: (flagNumber) =>
    # get the buildingTileSet from mapData, if it doesn't exist just return
    if mapData.buildingTileSets isnt undefined and mapData.buildingTileSets[flagNumber] isnt undefined
      buildingTileSet = mapData.buildingTileSets[flagNumber]
    else
      # clear the carousel and return
      carousel = $('#buildingCarousel').data('jcarousel')
      carousel.reset()
      $('#buildingCarousel').empty()
      $('.jcarousel-skin-tango .jcarousel-container-vertical').css('width', "75px") # reset width
      return
    
   
    #
    # update the carousel with the approriate thumbnails (1st frame) of the buildingTileSet
    #
    
    # firstly change the css properties for the items in the carousel so that each square place holder
    # in the carousel is the same size as each sprite also change the width of the whole carousel to fit
    $('.jcarousel-skin-tango .jcarousel-clip-vertical').css('height', "#{mapData.buildingTileSets[flagNumber].tileHeight}px")
    $('.jcarousel-skin-tango .jcarousel-clip-vertical').css('width', "#{mapData.buildingTileSets[flagNumber].tileWidth}px")
    $('.jcarousel-skin-tango .jcarousel-container-vertical').css('width', "#{mapData.buildingTileSets[flagNumber].tileWidth}px")
    
    
    
    
    spriteMap = mapData.buildingTileSets[flagNumber].spritesheet.src
    index = spriteMap.lastIndexOf("/") + 1
    filename = spriteMap.substr(index)
    carousel = $('#buildingCarousel').data('jcarousel')
    carousel.add 0, "<img style='top: 0px; position: relative;' src='image/grass.png' />"
    carousel.add 1, "<img style='top: 0px; position: relative;' src='image/dirt.png' />"
    carousel.size(2)
    
    ###
    $('#buildingCarousel').jcarousel({
      size: 1,
      itemLoadCallback: {onBeforeAnimation: (carousel, state) =>
        # fislty get filename from spritesheet.src (i.e. convert from url to just *****.png)
        spriteMap = mapData.buildingTileSets[flagNumber].spritesheet.src
        index = spriteMap.lastIndexOf("/") + 1
        filename = spriteMap.substr(index)
        
        carousel.add 0, "<img src='image/#{filename}' />"
        
        # add thumbnails to carousel
        for i in [1..mapData.buildingTileSets[flagNumber].numberOfBuildings] 
          offsetX = -i * mapData.buildingTileSets[flagNumber].tileHeight
          carousel.add i, "<img style='top: #{offsetX}px; position: relative;' src='image/#{filename}' />"
          console.log('i = ', i)
        
        }
    })
    ###
  
    
    
  # 
  #  Listen for button clicks on UI
  # 
   
  UIMouseDown: (e) =>
    
    # the id of the clicked on element
    idClickEle = e.target.getAttribute('id')
    
    # if the element clicked is canvas just ignore and return
    if idClickEle is 'canvas' then return
    
    
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
          @buildingSelectionToolBarVisible = false
          @toolSelect = null
        else # close the current one and open the new selected one
          @buildingSelectionToolBarVisible = idClickEle.substring(7,idClickEle.length)
          @loadBuildingData(@buildingSelectionToolBarVisible)
    
    # detect if other icons are selected
    switch idClickEle
      
      when 'zoomIn'
        @toolSelect = 'zoomIn'
        console.log('zoomIn')
    