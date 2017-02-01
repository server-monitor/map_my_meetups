require 'simplecov'
SimpleCov.start

# =+= bec. Zeus does not preload RSpec. Zeus will fail if this is not present.
# http://stackoverflow.com/questions/26073898/rspec-3-1-with-zeus-should-i-require-rspec-rails-in-spec-helper
require 'rspec/core' if !defined? RSpec.configure

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  # ... commented out originally
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  # ... commented out originally
  Kernel.srand config.seed
end

# ...
require 'rails_helper'
