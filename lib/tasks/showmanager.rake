namespace :showmanager do
  task :durfix => :environment do
    # repair durations in the database
    acts=Act.find(:all)
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
end
