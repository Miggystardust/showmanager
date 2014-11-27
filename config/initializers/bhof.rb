Rails3MongoidDevise::Application.configure do
  config.after_initialize do

  # constants, which we will move to a db at some point for the BHOF application
  ::BHOF_YEAR = '2015'
  ::BHOF_TITLE = "BHoF Weekend #{BHOF_YEAR}"
  ::BHOF_DISCOUNT_DEADLINE =  DateTime.new(2015,1,5,0,0,00,'-08:00')  #'11:59pm PDT on January 19, 2015'
  ::BHOF_FINAL_DEADLINE =  DateTime.new(2015,1,19,23,59,00,'-08:00')  #'11:59pm PDT on January 19, 2015'

  # application rates, in cents. If the current date is after the deadline, the new rates applies
  ::BHOF_RATES = [ { :deadline => DateTime.new(2000,1,1,0,0,00,'-08:00'), :rate => 2900 },
                   { :deadline => BHOF_DISCOUNT_DEADLINE, :rate => 3900 }]


  if Rails.env == 'development'
    ::BHOF_HOST = 'dev.troupeit.com'
  else
    ::BHOF_HOST = 'troupeit.com'
  end

  end
end
