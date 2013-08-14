FactoryGirl.define do
  factory :beta do
    name "Beta Test example"
  end

  factory :beta_active do 
    name "Active Beta"
#    self.begin 20.days.ago
#    self.end 20.days.since
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

