# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create(
  [
    {first_name: 'Uwe', last_name: 'Drechsel', email: 'uwe@insilmaril.de'},
    {first_name: 'Dagobert', last_name: 'Duck', email: 'test@insilmaril.de'}
  ]
)

0.upto(20) do |n| 
  User.create( {first_name: n, last_name: 'User', email: "user_#{n}@company.com"})
end


u = User.find(1)
u.admin = true
u.uid = 'http://insilmaril.myopenid.com/'
u.save!

betas = Beta.create(
  [
    {name: 'SUSE Cloud 2.0', begin: '2013-06-01', end: '2013-08-31'},
    {name: 'SUSE Linux Enterprise Server 11 SP3', begin: '2013-02-14', end: '2013-07-31'}
  ]
)
