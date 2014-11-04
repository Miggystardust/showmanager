class Entry
  include Mongoid::Document
  field :name, type: String

  field :type, type: Integer  # 1 if solo, 2 if group
  field :num_performers, type: Integer    # "1" if a solo act
  field :all_performer_names, type: String  # "1" if a solo act

  field :city_from, type: String
  field :country_from, type: String
  field :performer_url, type: String

  field :category, type: Integer # not used? 
  field :compete_preference, type: Integer

  field :video_url, type: String
  field :years_applied, type: String
  field :years_performed, type: String
  field :other_stage_names, type: String
  field :favorite_thing, type: String
  field :years_experience, type: String
  field :style, type: String
  field :why_act_unique, type: String
  field :outside_work, type: String
  field :comments, type: String
end
