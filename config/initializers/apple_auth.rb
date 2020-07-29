# frozen_string_literal: true

AppleAuth.configure do |config|
  config.apple_client_id = ENV.fetch('APPLE_CIENT_ID')
  config.apple_private_key = ENV.fetch('APPLE_PRIVATE_KEY')
  config.apple_key_id = ENV.fetch('APPLE_KEY_ID')
  config.apple_team_id = ENV.fetch('APPLE_TEAM_ID')
  config.redirect_uri = ENV.fetch('APPLE_REDIRECT_URL')
end
