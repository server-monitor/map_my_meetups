
# This whole thing is not needed?!
# require 'billy/capybara/rspec'

# Billy.configure do |billy|
#   billy.cache = true
#   billy.persist_cache = true
#   billy.cache_path = Rails.root.join(
#     'spec', 'fixtures', 'puffing_billy_cache'
#   )
# end

# # need to call this because of a race condition between persist_cache
# # being set and the proxy being loaded for the first time
# Billy.proxy.reset_cache

# ... apparently not needed anymore.
# RSpec.configure do |config|
#   config.around :each, js: true, js_vcr: true do |example|
#     Capybara.current_driver = :selenium_chrome_billy
#     Capybara.javascript_driver = :selenium_chrome_billy
#     # Capybara.current_driver = :webkit_billy
#     # Capybara.javascript_driver = :webkit_billy

#     WebMock.allow_net_connect!

#     example.run

#     Capybara.use_default_driver
#     Capybara.javascript_driver = :selenium

#     # Reconfigure back to VCR/WebMock default.
#     WebMock.disable_net_connect!
#     # WebMock.disable_net_connect!(allow_localhost: true)
#   end
# end

# Config doc
# # https://github.com/oesmith/puffing-billy
# Billy.configure do |c|
#   c.cache = true
#   c.cache_request_headers = false
#   c.ignore_params = ["http://www.google-analytics.com/__utm.gif",
#                      "https://r.twimg.com/jot",
#                      "http://p.twitter.com/t.gif",
#                      "http://p.twitter.com/f.gif",
#                      "http://www.facebook.com/plugins/like.php",
#                      "https://www.facebook.com/dialog/oauth",
#                      "http://cdn.api.twitter.com/1/urls/count.json"]
#   c.path_blacklist = []
#   c.merge_cached_responses_whitelist = []
#   c.persist_cache = true
#   c.ignore_cache_port = true # defaults to true
#   c.non_successful_cache_disabled = false
#   c.non_successful_error_level = :warn
#   c.non_whitelisted_requests_disabled = false
#   c.cache_path = 'spec/req_cache/'
#   c.proxy_host = 'example.com' # defaults to localhost
#   c.proxy_port = 12345 # defaults to random
#   c.proxied_request_host = nil
#   c.proxied_request_port = 80
#   c.cache_request_body_methods = %w[post patch put] # defaults to ['post']
# end
