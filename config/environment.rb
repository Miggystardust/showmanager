# Load the rails application
require File.expand_path('../application', __FILE__)

UPLOADS_DIR = "#{Rails.root}/uploads"
THUMBS_DIR = "#{Rails.root}/thumbs"

# our shortened time format
# Sun Jan 1, 2012 5:00 PM 
SHORT_TIME_FMT = "%a %b %d, %Y %I:%M %p"
TIME_ONLY_FMT = "%I:%M %p"

# FB Integration
FACEBOOK_APP_ID = '308336679243664'

# Initialize the rails application
Rails3MongoidDevise::Application.initialize!

