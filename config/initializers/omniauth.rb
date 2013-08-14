Rails.application.config.middleware.use OmniAuth::Builder do
  require 'openid/store/filesystem'
  provider :open_id
  provider :open_id, :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'
end

OmniAuth.config.on_failure = Proc.new { |env|
    OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
