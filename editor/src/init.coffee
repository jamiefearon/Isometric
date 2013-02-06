
assetManager = null
game = null

# this contains all map data to be saved to JSON
mapData = {}

init = =>


  ###

  

  This init function is also called on the start screen, so remove this script 
  from start_screen header. 

  Make a new script which only loads on start_screen. This script will collect info settings default
  tile etc. When user clicks submit all this data is sent to the servor and then the servor does 
  a self.redirect('editor/?r=' + varable ) etc.



  ###

  console.log 'hello mimi'
  
  # Get the relevent URL Parameters to construct the map
  query_rows = $.query.get("r")
  query_columns = $.query.get("c")
  query_defaultTile_name = $.query.get("t")
  
  
  # Load resources if not already loaded
  if !assetManager
    assetManager = new AssetManager()
    loader = new PxLoader()

    # Load the Default Tile
    assetManager.addAsset(loader.addImage("image/#{query_defaultTile_name}.png"), query_defaultTile_name)

    assetManager.addAsset(loader.addImage('image/sprite1.png'), 'sprite1')
    assetManager.addAsset(loader.addImage('image/tree.png'), 'tree')
    assetManager.addAsset(loader.addImage('image/cinema.png'), 'cinema')
    
    loader.addCompletionListener =>
      # get the user selected number of rows, colunms and default tile
      numRows = parseInt(query_rows) or 4
      numCols = parseInt(query_columns) or 4
      defaultTile = query_defaultTile_name or 'grass'
      game = new Game(numRows, numCols, defaultTile)
    
    # begin downloading images 
    loader.start(); 
    
    
    
    
    

# Start it all off
$(document).ready(init)