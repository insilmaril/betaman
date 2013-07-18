FactoryGirl.define do
  factory :user do
    first_name "John"
    last_name "Doe"
    admin false
    email "jdoe@company.com"
  end
end