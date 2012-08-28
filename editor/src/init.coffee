
assetManager = null

# this contains all map data to be saved to JSON
mapData = {}

init = =>
    
  # Setup the building carosol
  $('#buildingCarousel').jcarousel({
    vertical : true
  })
  
  
  mapData.meow = 2 # TEMP
  
  
  # Load resources if not already loaded
  if !assetManager
    $('#gameIntro').hide()
    assetManager = new AssetManager()
    loader = new PxLoader()
    assetManager.addAsset(loader.addImage('image/sprite1.png'), 'sprite1')
    assetManager.addAsset(loader.addImage('image/grass.png'), 'grass')
    assetManager.addAsset(loader.addImage('image/dirt.png'), 'dirt')
    
    loader.addCompletionListener =>
      $('#gameIntro').show() 
    
    # begin downloading images 
    loader.start(); 
    
    
  # Player clicks play and the fun begins 
  $('#userSubmit').click (e) ->
    
    # hide the start userinterface
    e.preventDefault()
    $('#menu').hide('slow')
    
    # get the user selected number of rows, colunms and default tile
    numRows = parseInt($('#userRows').val()) or 4
    numCols = parseInt($('#userCols').val()) or 4
    defaultTile = $('#userDefaultTile').val() or 'grass'
    
    game = new Game(numRows, numCols, defaultTile)
    

# Start it all off
$(document).ready(init)