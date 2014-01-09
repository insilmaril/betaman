#!/usr/bin/env ruby

employee = Role.where( name: "Employee").first
tester = Role.where( name: "Tester").first

if employee.nil? || tester.nil?
  raise "Couldn't find necessary roles in database"
end

suse = Company.where( name: "SUSE").first
if suse.nil?
  raise "Couldn't find SUSE in database"
end

novell = Company.where( name: "Novell").first
if novell.nil?
  raise "Couldn't find Novell in database"
end

User.all.each do |u|
  if /suse\.(de|com|cz)$/.match(u.email)
    puts "Internal: #{u.email} SUSE"
    if u.company != suse
      puts "  Setting company to #{suse.name}"
      u.company = suse

    end
    if !u.roles.include?(employee)
      puts "  Adding role #{employee.name}"
      u.roles << employee
    end
    u.save!
  elsif /novell\.com$/.match(u.email)
    puts "Internal: #{u.email} Novell"
    if u.company != novell
      puts "  Setting company to #{novell.name}"
      u.company = novell
    end
    if !u.roles.include?(employee)
      puts "  Adding role #{employee.name}"
      u.roles << employee
    end
    u.save!
  else
    puts "External: #{u.email}"
    if u.roles.include?(employee)
      puts "Dropping role #{employee.name}"
      u.roles.delete(employee)
      u.save!
    end
  end
end