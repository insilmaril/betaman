#!/usr/bin/env script/rails runner

begin
  # Login to any beta hosted at Novell
  beta1 = Beta.find(1)
  users = beta1.users.external
  users.each do |user|
    puts user.email
  end
end
