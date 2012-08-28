
assetManager = null

init = =>
  
  # Load resources if not already loaded
  if !assetManager
    $('#gameIntro').hide()
    assetManager = new AssetManager()
    assetManager.queueDownload('image/grass.png')
    assetManager.downloadAll ->
      #$('#loading').hide()
      $('#gameIntro').show()  
    
    
  # Player clicks play and the fun begins 
  $('#gamePlay').click (e) ->
    e.preventDefault()
    $('#gameIntro').hide()
    $('#title').hide()
    window.game = new Game()
    #game.play()
    


# Start it all off
$(document).ready(init)