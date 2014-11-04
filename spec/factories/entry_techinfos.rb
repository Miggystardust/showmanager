# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :entry_techinfo do
    entry_id ""
    song_title ""
    song_artist ""
    act_duration_secs ""
    act_name ""
    act_description ""
    costume_Description ""
    costume_colors ""
    props ""
    other_tech_info ""
    setup_needs ""
    setup_time_secs 1
    breakdown_needs ""
    breakdown_time_secs ""
    sound_cue ""
    microphone_needs ""
    lighting_needs ""
    mc_intro ""
    aerial_needs ""
  end
end
