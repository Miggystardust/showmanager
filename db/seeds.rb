# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def random_password(size = 8)
  chars = (('a'..'z').to_a + ('0'..'9').to_a) - %w(i o 0 1 l 0)
  (1..size).collect{|a| chars[rand(chars.size)] }.join
end

puts 'Empty MongoDB...'

Mongoid.master.collections.reject { |c| c.name =~ /^system/}.each(&:drop)

puts 'Configure Roles...'

r = Role.create! :name => 'admin', :description => "Full Admin Access"
r1 = Role.create! :name => 'stage_manager', :description => "All Access except User edits and Passet Edit"
r2 = Role.create! :name => 'crew', :description => "Read Only Show Access"

puts 'Create Admin User...'
password = random_password(8)

user = User.create! :username => 'admin', :name => 'Admin User', :email => 'admin@example.com', :password => password, :password_confirmation => password

# have to set these seperately because of mass-assignment protection
user.admin = true
user.roles << r1
user.save!

puts "New Admin user created: email: #{user.email} p: #{user.password}"
