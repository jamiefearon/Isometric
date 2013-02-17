class UI

  constructor: (parameters) ->
    
    # set the action of the left mouse button on the toolbar
    window.addEventListener 'mousedown', (e) =>
      button = e.which or e.button
      if button == 1 then @UIMouseDown(e) # Left mouse click
    , false

    @bts_json = null;            # contains the completed parsed json for the bts(building tile set)
    @bts_spritesheet = null;     # contains the completed spritesheet for the bts (building tile set)
    @bts_spritesheet_file = null; # raw file used for uploading
    
    # @toolSelect contains a string representing the selected tool
    @toolSelect = null
    @selectedBuilding = null
    @zoomLevel = 1;

    # the selected building thumb in BuildingSelectonDialog
    @selectedThumb = null
    
    # @buildingSelectionToolBarVisible equals the number of the flag if selected, else false
    @buildingSelectionToolBarVisible = false
  
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

    # grey out the frame number input box as this can't be modified
    $("#numberFrames").prop('disabled', true)


    flagNumber = id.substring(7,id.length)
    buildingTileSet = undefined

    # 
    #  Gets the JSON from the user (using HTML5 File API) and converts it the type we need.
    #
    #
    #  See the Fiddle here http://jsfiddle.net/jamiefearon/8kUYj/50/ to play about with and update the 
    #  conversion of the texture packer object to the corrected super dooper isogame one :) :) :) :) :)
    
    handleJSONSelection = (evt) => 
      files = evt.target.files
      f = files[0];
      reader = new FileReader()

      # Closure to capture the file information.
      reader.onload = ((theFile) =>
        return (e) => 
          JsonObj = e.target.result
          console.log(JsonObj)
          parsedJSON = JSON.parse(JsonObj)
          
          # Convert Raw Texture Packer JSON into a Building Tile Set JSON
            
          # 1. detect animation sprites and collete the frames into multi frames
          oldframes = parsedJSON.frames
          newframes = {}
          for framename of oldframes 
            m = framename.match(/^(.+?)(\d*)\.png$/)
            newname = m[1]
            frame = oldframes[framename]
  
            if !(newname of newframes) # in coffescript the of keyword is the in keyword
              newframes[newname] =
                size: frame.sourceSize,
                tile: {baseW:0, baseH:0, drawW:0, drawH:0}

              if (m[2]) # animation case
                newframes[newname] =
                  size: frame.sourceSize,
                  tile: {baseW:0, baseH:0, drawW:0, drawH:0}
                  animation: {frames:0, speed:0}
                  frames: {}


                #newframes[newname].frames = {}
                


                
            if (m[2]) 
              newframes[newname].frames["frame" + m[2]] = frame.frame
            else 
              newframes[newname].frame = frame.frame
           
          parsedJSON.frames = newframes
            
          # 2. Remove the meta property
          delete parsedJSON.meta
            
          # 3. Rename the "frames" main parent property to name of building tile set
          parsedJSON.name = parsedJSON.frames
          delete parsedJSON.frames

          # 4. Set the number of frames property
          _.each parsedJSON.name, (val) =>
            if _.has(val, 'animation')
              val.animation.frames = _.size(val.frames)
            
          # Stringify the JSON and print the result to the console
          JsonObj = JSON.stringify(parsedJSON, null, 4)
          console.log(JsonObj)

          @bts_json = parsedJSON

        )(f)
      reader.readAsText(f, 'UTF-8')
    document.getElementById('upload_JSON').addEventListener('change', handleJSONSelection, false)


   
    ##
    #  Gets the Spritesheet from the user (using HTML5 File API)
    ##
    
    handleSpritesheetSelection = (evt) => 
      files = evt.target.files
      f = files[0]
      @bts_spritesheet_file = f
      reader = new FileReader()

      # Closure to capture the file information.
      reader.onload = ((theFile) =>
        return (e) => 
          @bts_spritesheet = e.target.result   
        )(f)
      reader.readAsDataURL(f)
    document.getElementById('upload_spritesheet').addEventListener('change', handleSpritesheetSelection, false)
    
      

   ##
   # display the building thumbs, the the user clickes on id="display_building_thumbs"
   ##
    $('#display_building_thumbs').click () =>
      
      buildingNames = @bts_json.name
      for buildingFrame of buildingNames # For each building frame
        do (buildingFrame) => #DOC: http://stackoverflow.com/questions/14821951/only-the-last-value-of-for-of-loop-being-passed-to-jquery-click-function/14822054#14822054
          # 1st case, only 1 frame exists (i.e. not an animation)
          if (buildingNames[buildingFrame].hasOwnProperty("frame"))
            w = buildingNames[buildingFrame]["size"]["w"]   # Width of building sprite
            h = buildingNames[buildingFrame]["size"]["h"]   # Height of building sprite
            x = buildingNames[buildingFrame]["frame"]["x"]   # x position of building sprite
            y = buildingNames[buildingFrame]["frame"]["y"]   # y position of building sprite
            $('#building_thumb_view').append("<div class='tile_wrap' id='bt-#{buildingFrame}' style='
                                              background-image:url(#{@bts_spritesheet});
                                              background-position:-#{x}px -#{y}px;
                                              width:#{w}px; 
                                              height:#{h}px;
                                              '>#{buildingFrame}</div>")
         
          # 2st case, multible frames exists (i.e. is an animation)
          if (buildingNames[buildingFrame].hasOwnProperty("frames"))
            w = buildingNames[buildingFrame]["size"]["w"]   # Width of building sprite
            h = buildingNames[buildingFrame]["size"]["h"]   # Height of building sprite
            x = buildingNames[buildingFrame]["frames"]["frame1"]["x"]   # x position of building sprite
            y = buildingNames[buildingFrame]["frames"]["frame1"]["y"]   # y position of building sprite
            $('#building_thumb_view').append("<div class='tile_wrap' id='bt-#{buildingFrame}' style='
                                              background-image:url(#{@bts_spritesheet});
                                              background-position:-#{x}px -#{y}px;
                                              width:#{w}px; 
                                              height:#{h}px;
                                              '>#{buildingFrame}</div>")
          
          # call display properties function if a building thumb is cicked on
          overlay = $('.tile_wrap')
          $("#bt-#{buildingFrame}").click () =>
            if $("#bt-#{buildingFrame}").hasClass('selected')
              $("#bt-#{buildingFrame}").removeClass('selected')
              @selectedThumb = null

              # Clear input values
              $('#baseWidth').val('')
              $('#baseHeight').val('')
              $('#drawWidth').val('')
              $('#drawHeight').val('')
              $('#numberFrames').val('')
              $('#animationSpeed').val('')

            else
              if $('[id^="bt-"]').hasClass('selected') then $('[id^="bt-"]').removeClass('selected') # remove the class from any thumbs already selected
              overlay.removeClass('selected')
              $("#bt-#{buildingFrame}").addClass('selected')
              @selectedThumb = buildingFrame # Set the class propertiy @selectedThumb to the user selected building for use in the @changeProperties() function
              @displayProperties(buildingFrame)

      

    # Call changeProperties() when user clicks on the Set Properties button
    $('#changeProperties').click () => @changeProperties()

    # Uploads the bts when user clicks on upload bts (i.e the spritesheet and the Json)
    $('#uploadbts').click () => @uploadBTS()

          
  # Displays a buildings properties for a selected building
  displayProperties: (buildingThumbName) =>

    buildingNames = @bts_json.name
    $('#baseWidth').val(buildingNames[buildingThumbName]['tile'].baseW)
    $('#baseHeight').val(buildingNames[buildingThumbName]['tile'].baseH)
    $('#drawWidth').val(buildingNames[buildingThumbName]['tile'].drawW)
    $('#drawHeight').val(buildingNames[buildingThumbName]['tile'].drawH)
    
    if buildingNames[buildingThumbName].hasOwnProperty("frames")
      $('#numberFrames').val(buildingNames[buildingThumbName]['animation'].frames) 
      $('#animationSpeed').val(buildingNames[buildingThumbName]['animation'].speed)
      $("#animationSpeed").prop('disabled', false);
    else
      $('#numberFrames').val('')
      $('#animationSpeed').val('')
      $("#animationSpeed").prop('disabled', true);


  # Changes the selected buildings properties based on user input
  changeProperties: () =>
    console.log 'Thumb to change is', @selectedThumb
    buildingNames = @bts_json.name
    if @selectedThumb isnt null
      buildingNames[@selectedThumb]['tile'].baseW = $('#baseWidth').val()
      buildingNames[@selectedThumb]['tile'].baseH = $('#baseHeight').val()
      buildingNames[@selectedThumb]['tile'].drawW = $('#drawWidth').val()
      buildingNames[@selectedThumb]['tile'].drawH = $('#drawHeight').val()

      if buildingNames[@selectedThumb].hasOwnProperty("frames")
        buildingNames[@selectedThumb]['animation'].speed = $('#animationSpeed').val()
      
    JsonObj = JSON.stringify(@bts_json, null, 4)
    console.log(JsonObj)


  uploadBTS: () =>
    name = $('#btsName').val()
   
    formData = new FormData()
    formData.append('bts_jason', @bts_json)
    formData.append('bts_name', name)
    formData.append('bts_spriteSheet', @bts_spritesheet_file)

    xhr = new XMLHttpRequest()
    xhr.open('POST', '/uploadBTS', true)
    xhr.onload = (e) =>
      console.log 'yay its done'
    xhr.send(formData)


    ###
    $.post "/uploadBTS?bts_spriteSheet=#{@bts_spritesheet_url}&bts_jason=#{@bts_json}&bts_name=#{name}", (data) =>
      console.log 'succsess' 
    ###
  

              
    


  
  #
  #  put the correct BULIING_TILESET thumnails into build toolbar
  #
  
  loadBuildingData: (flagNumber) =>
   
    
    
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
