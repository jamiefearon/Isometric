# Extend this as the main game class

class IsoGame
 
  # game settings
  @settings =
    techStats: false

  constructor: ->
    
    @renderer = null
    
    # fps calculation variables
    @frameCount = 0
    @fps = 0
    @startTime = (new Date()).getTime()
  
  
  # The main Game loop      
  animloop: =>
    
    requestAnimFrame @animloop
    
    # calculate the fps
    @frameCount++
    currentTime = (new Date()).getTime()
    if currentTime - @startTime > 1000
        @fps = @frameCount
        @frameCount = 0
        @startTime = (new Date()).getTime()
            
           


  # creates the renderer and sets the context
  createRenderer: (type) =>
    
    if type == 'canvas'
      @renderer = new CanvasRenderer
      Sprite.renderer = @renderer  # tell Sprite which renderer to use
      IsometricGrid.renderer = @renderer
    else
      return
      # create webgl renderer
    

  # Call this to display fps
  displayFps: =>
    $("#fps").html(@fps)
    
    
  # Show tech stats if true
  displayTech: (value) =>
    if value
      $("#stats").css("visibility","visible")
      IsoGame.settings.techStats = true
    else
      $("#stats").css("visibility","hidden")
      IsoGame.settings.techStats = false
      
  
  