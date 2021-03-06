FactoryGirl.define do
  factory :user do
    first_name "John-User"
    last_name "Doe"
    email "user@company.com"

    factory :user_with_account do
      after_create do |user|
        user.add_account("a.provider", "http://user.myopenid.com")
        user.save!
      end
    end

    factory :user_regular do
      after_create do |user|
        user.add_account("a.provider", "http://user.myopenid.com")
        user.save!
      end
    end

    factory :user_employee do
      after_create do |user|
        user.first_name = 'John-Employee'
        user.add_account("a.provider", "http://user.myopenid.com")
        user.make_employee
        user.save!
      end
    end

    factory :user_with_beta do
      after_create do |user|
        user.first_name = 'John with beta'
        beta = FactoryGirl.create(:beta)
        user.betas << beta
        user.save!
      end
    end

    factory :user_admin do
      after_create do |user|
        user.add_account("a.provider", "http://admin.myopenid.com")
        user.email = "admin@company.com"
        user.first_name = 'John-Admin'
        user.make_admin
        user.save!
      end
    end
  end

  factory :account do
    uid "http://user@myopenid.com"
  end
end

