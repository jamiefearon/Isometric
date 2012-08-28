
class AssetManager

  constructor: ->
    
    @cache = {}


  addAsset: (image, tag) ->
    @cache[tag] = image
    console.log('adding ' + tag)
   
  getAsset: (tag) ->
    console.log('getting ' + tag)
    return @cache[tag]
    