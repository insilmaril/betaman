FactoryGirl.define do
  factory :beta do
    self.name  "Beta Test example"
    self.begin 100.days.ago
    self.end   20.days.since

    factory :beta_active do 
      after_create do |beta|
        beta.name = "Active Beta example"
        beta.begin = 20.days.ago
        beta.end   = 20.days.since
        beta.save!
      end
    end
  end

=begin
  factory :beta_finished do |beta|
    name "Finished Beta"
    beta.begin = 40.days.ago
    beta.end = 20.days.ago
  end

  factory :beta_planned do |beta|
    name "Planned  Beta"
    beta.begin = 20.days.since
    beta.end = 40.days.since
  end
=end
end

