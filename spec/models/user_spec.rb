
describe User do
  it { should respond_to :name }
  # it { should respond_to :email }
  it { should have_many :meetup_events }
end
