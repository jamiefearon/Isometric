import jinja2
import os
import webapp2

from google.appengine.ext import db

# initialise the jinja2 template framework
jinja_environment = jinja2.Environment(
    loader=jinja2.FileSystemLoader(os.path.dirname(__file__)))


# Database containg the default tiles for user selection
class Default_tiles(db.Model):
  name = db.StringProperty()
  image = db.BlobProperty(default=None)




# Handler for the introduction screen for loading or creating a new map
class StartScreen(webapp2.RequestHandler):
  def get(self):

    # Get all (actually first 100, there should not be more then this) the default tiles in the database
    default_tiles_query = Default_tiles.all()
    defaultTiles = default_tiles_query.fetch(100)

    # All variable to be sent to the template
    template_values = {
    	'defaultTiles': defaultTiles,  # contain all the defaut tiles to be displayed
    }

    template = jinja_environment.get_template('start_screen.html')
    self.response.out.write(template.render(template_values))


# Handler for calls to '/default_tile_img' GET this locally to fetch default tiles.
class Get_default_tile(webapp2.RequestHandler):
  def get(self):
    name = self.request.get('image_name')  		# Get the image_name from client
    default_tile = self.get_default_tile(name)  # Get image_name tile from database 
    
    # Send the image back to the client
    self.response.headers['Content-Type'] = "image/png"
    self.response.out.write(default_tile.image)

  # Querys the data base for image_name and returns the default tile named image_name
  def get_default_tile(self, name):
    result = db.GqlQuery("SELECT * FROM Default_tiles WHERE name = :1 LIMIT 1", name).fetch(1)
    if (len(result) > 0):
      return result[0]
    else:
      return None


# Handler for calls to '/upload' POST here to upload default tiles
class Upload(webapp2.RequestHandler):
  def post(self):
   
    # get information from form post upload
    image_url = self.request.get('image_url') 
    image_name = self.request.get('image_name')

    # create database entry for uploaded image 
    default_tile = Default_tiles()
    default_tile.name = image_name
    default_tile.image = db.Blob(image_url)
    default_tile.put()

    self.redirect('/')





# The actual editor
class Editor(webapp2.RequestHandler):
  def get(self):
    template = jinja_environment.get_template('index.html')
    self.response.out.write(template.render())




app = webapp2.WSGIApplication([('/', StartScreen),
							   ('/editor', Editor),
							   ('/upload', Upload),
							   ('/default_tile_img', Get_default_tile)],
                              debug=True)
