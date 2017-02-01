
describe Venue do
  it { should belong_to :meetup_event }
  it { should validate_presence_of :latitude }
  it { should validate_presence_of :longitude }

  context 'when input is ocruby event' do
    let(:event) { create :meetup_event, :ocruby_event }

    describe '#venue' do
      RSpecUtil::OCRUBY_EVENT_VENUE.each do |attri, exp|
        describe attri do
          specify do
            expect(event.venue.public_send(attri)).to eq exp
          end
        end
      end
    end
  end
end
