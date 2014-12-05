namespace :showmanager do
  task :durfix => :environment do
    # convert old-style durations which were minute based to new style, which
    # are seconds based
    acts=Act.all
    acts.each { |a| 
      a.length = a.length * 60
      a.save!
    }  
  
    sis=ShowItem.find(:all)

    sis.each { |s| 
      if s.duration > 0 
        s.duration = s.duration * 60
        s.save!
      end
    }
  end

  task :move_to_hubba => :environment do
    # covert every show in the system to hubba hubba's troupe_id

    hubba_troupe = Troupe.where(name: 'Hubba Hubba Revue')[0]
    if hubba_troupe
       shows = Show.all
       shows.each { |theshow| 
         puts "Migrate #{theshow.title} #{theshow._id}..."
         theshow.troupe_id = hubba_troupe._id
         theshow.save! 
       }
    else 
      print "can't find hubba troupe."
    end
  end
end
