# Load the rails application
require File.expand_path('../application', __FILE__)

UPLOADS_DIR = "#{Rails.root}/uploads"
THUMBS_DIR = "#{Rails.root}/thumbs"

# Initialize the rails application
Rails3MongoidDevise::Application.initialize!
