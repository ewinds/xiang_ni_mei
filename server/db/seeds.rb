# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
puts 'ROLES'
Setting.ROLES.each do |role|
  Role.find_or_create_by_name(role)
  puts 'role: ' << role
end
puts 'DEFAULT USERS'
user = User.find_or_create_by_user_name(
    :user_name => Setting.ADMIN_NAME.dup,
    :email => Setting.ADMIN_EMAIL.dup,
    :password => Setting.ADMIN_PASSWORD.dup,
    :password_confirmation => Setting.ADMIN_PASSWORD.dup)
user.reset_authentication_token!
puts 'user: ' << user.user_name
user.confirm!
user.add_role :admin

puts 'random users'
100.times do
  password = "#{Faker::numerify('######')}"
  user = User.find_or_create_by_user_name(
      :user_name => "#{Faker::numerify('######')}",
      :email => "#{password}@bless.com",
      :password => password.dup,
      :password_confirmation => password.dup)
  user.confirm!
  user.reset_authentication_token!
end