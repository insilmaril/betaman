#
# Create default roles
#
role_admin = Role.new(name: "Admin")
role_admin.save
role_empl = Role.new(name: "Employee")
role_empl.save
role_tester = Role.new(name: "Tester")
role_tester.save


#
# Create admin user
#

admin = User.create({
  first_name: 'Ada', 
  last_name: 'Admin' } )
admin.accounts << Account.new(uid: 'https://profiles.google.com/108569392878826067352')
Role.all.each do |r|
  admin.roles << r
end
admin.save

#
# Create some data for playing in development environment
#

if Rails.env == 'development'

  # Create some test users
  u = User.new
  u.first_name = 'Eva'
  u.last_name = 'Employee'
  u.email = 'test@insilmaril.de'
  u.roles << role_empl
  u.accounts << Account.new(uid: 'http://vym.myopenid.com/')
  u.save

  0.upto(20) do |n| 
    User.create( {first_name: n, last_name: 'User', email: "user_#{n}@company.com"})
  end


  # Create some test betas
  betas = Beta.create(
    [
      {name: 'SUSE Cloud 2.0', begin: '2013-06-01', end: '2013-08-31'},
      {name: 'SUSE Linux Enterprise Server 11 SP3', begin: '2013-02-14', end: '2013-07-31'}
  ]
  )

  # Add some test betas to user
  User.find_by_email('uwe@insilmaril.de').betas << Beta.all
end

