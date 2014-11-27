# Load the rails application
require File.expand_path('../application', __FILE__)

# true/false monkeypatch
require "#{Rails.root}/lib/yesno.rb"

if ENV['RAILS_ENV'] == 'production'
  UPLOADS_DIR = "/retina/hubba/showmanager-data/uploads"
  THUMBS_DIR = "/retina/hubba/showmanager-data/thumbs"
else
  UPLOADS_DIR = "#{Rails.root}/uploads"
  THUMBS_DIR = "#{Rails.root}/thumbs"
end

# our shortened time format
# Sun Jan 1, 2012 5:00 PM
# we're assuming an english-us locale ho well!
SHORT_TIME_FMT = "%a %b %d, %Y %I:%M %p"
SHORT_TIME_FMT_TZ = "%a %b %d, %Y %I:%M %p %Z"
SHORT_DATE_FMT = "%a %b %d, %Y"

TIME_ONLY_FMT = "%I:%M %p"
TIME_ONLY_FMT_TZ = "%I:%M %p %Z"

# FB Integration
FACEBOOK_APP_ID = '308336679243664'

# Initialize the rails application
Rails3MongoidDevise::Application.initialize!


