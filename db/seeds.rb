# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

users = User.create(
  [
    {first_name: 'Uwe', last_name: 'Drechsel', email: 'uwe@insilmaril.de'},
    {first_name: 'Dagobert', last_name: 'Duck', email: 'test@insilmaril.de'}
  ]
)

u = users.first
u.set_admin(true)
u.set_uid('http://insilmaril.openid.com/')
u.save!

betas = Beta.create(
  [
    {name: 'SUSE Cloud 2.0', begin: '2013-06-01', end: '2013-08-31'},
    {name: 'SUSE Linux Enterprise Server 11 SP3', begin: '2013-02-14', end: '2013-07-31'}
  ]
)
