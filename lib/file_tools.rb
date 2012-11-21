module FileTools
  class << self
    def sanitize_filename(file_name)
      # get only the filename, not the whole path (from IE)
      just_filename = File.basename(file_name)
      # replace all none alphanumeric, underscore or perioids
      # with underscore
      just_filename.sub(/[^\w\.\-]/,'_')
    end
  end
end
