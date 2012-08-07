ENV['FACEBOOK_KEY'] = '506664156016581'
ENV['FACEBOOK_SECRET'] = 'd7d94c6759bebb685bdb136cfeeb58c2'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'],
            scope:  'user_birthday,publish_stream'
end