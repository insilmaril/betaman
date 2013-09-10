# Create default roles
r = Role.new(name: "Admin")
r.save
r = Role.new(name: "Employee")
r.save
r = Role.new(name: "Tester")
r.save

if Rails.env == 'development'

  User.create(
    [
      {first_name: 'Uwe', last_name: 'Drechsel', email: 'uwe@insilmaril.de'},
      {first_name: 'Dagobert', last_name: 'Duck', email: 'test@insilmaril.de'}
  ]
  )

  u = User.find(1)
  u.admin = true
  u.accounts << Account.new(uid: 'http://insilmaril.myopenid.com/')
  u.save!

  Role.all.each do |r|
    u.roles << r
  end

  u = User.find(2)
  u.accounts << Account.new(uid: 'http://vym.myopenid.com/')
  u.save!

  0.upto(20) do |n| 
    User.create( {first_name: n, last_name: 'User', email: "user_#{n}@company.com"})
  end


  betas = Beta.create(
    [
      {name: 'SUSE Cloud 2.0', begin: '2013-06-01', end: '2013-08-31'},
      {name: 'SUSE Linux Enterprise Server 11 SP3', begin: '2013-02-14', end: '2013-07-31'}
  ]
  )

  # Create some relations
  User.find_by_email('uwe@insilmaril.de').betas << Beta.all
end

