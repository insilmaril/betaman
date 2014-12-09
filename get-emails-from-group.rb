#!/usr/bin/env script/rails runner

begin
  group = Group.find 12
  users = group.users.external
  users.each do |user|
    puts user.email
  end
end
