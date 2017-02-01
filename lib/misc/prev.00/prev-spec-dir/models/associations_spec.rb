
describe 'Model associations' do
  describe User do
    it { should have_many :meetup_events }
  end

  describe MeetupEvent do
    it { should belong_to :user }
    it { should have_one :venue }
  end

  describe Venue do
    it { should belong_to :meetup_event }
  end
end
