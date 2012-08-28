
assetManager = null

init = =>
  
  # Load resources if not already loaded
  if !assetManager
    $('#gameIntro').hide()
    assetManager = new AssetManager()
    loader = new PxLoader()
    assetManager.addAsset(loader.addImage('../images/sprite1.png'), 'sprite1')
    assetManager.addAsset(loader.addImage('../images/grass.png'), 'grass')
    
    loader.addCompletionListener =>
      console.log('oh double fuck sake oh no')
      $('#gameIntro').show() 
    
    # begin downloading images 
    loader.start(); 
    
    
  # Player clicks play and the fun begins 
  $('#gamePlay').click (e) ->
    e.preventDefault()
    $('#gameIntro').hide()
    $('#title').hide()
    game = new Game()
    

# Start it all off
$(document).ready(init)