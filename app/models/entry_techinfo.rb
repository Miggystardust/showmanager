class EntryTechinfo
  include Mongoid::Document
  field :entry_id, type: Id
  field :song_title, type: String
  field :song_artist, type: String
  field :act_duration_secs, type: Integer
  field :act_name, type: String
  field :act_description, type: String
  field :costume_Description, type: String
  field :costume_colors, type: String
  field :props, type: String
  field :other_tech_info, type: String
  field :setup_needs, type: String
  field :setup_time_secs, type: Integer
  field :breakdown_needs, type: String
  field :breakdown_time_secs, type: Integer
  field :sound_cue, type: String
  field :microphone_needs, type: String
  field :lighting_needs, type: String
  field :mc_intro, type: String
  field :aerial_needs, type: String
end
