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
  a = []
  changed = false
  if /suse\.(de|com|cz)$/.match(u.email)
    a << "Internal: #{u.email} SUSE"
    if u.company != suse
      a << "  Setting company to #{suse.name}"
      u.company = suse
      changed = true
    end
    if !u.roles.include?(employee)
      a << "  Adding role #{employee.name}"
      u.roles << employee
      changed = true
    end
  elsif /novell\.com$/.match(u.email)
    a << "Internal: #{u.email} Novell"
    if u.company != novell
      a << "  Setting company to #{novell.name}"
      u.company = novell
      changed = true
    end
    if !u.roles.include?(employee)
      a << "  Adding role #{employee.name}"
      u.roles << employee
      changed = true
    end
  else
    a << "External: #{u.email}"
    if u.roles.include?(employee)
      a << "  Dropping role #{employee.name}"
      u.roles.delete(employee)
      changed = true
    end
  end
  if changed
    puts a.join "\n"
  end
end