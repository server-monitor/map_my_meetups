require 'zeus/rails'

class CustomPlan < Zeus::Rails
  def test(*args)
    ENV['GUARD_RSPEC_RESULTS_FILE'] = File.expand_path(
      File.join(*%w[.. tmp guard_rspec_results.txt]), __FILE__
    )
    super
  end
end

Zeus.plan = CustomPlan.new
