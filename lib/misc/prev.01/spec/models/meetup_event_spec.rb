
describe MeetupEvent, type: :model do
  it { should belong_to :user }

  describe '#venue association' do
    let(:venue) { :venue }
    it { should have_one venue }
    it { should validate_presence_of venue }

    specify do
      expect(
        described_class.reflect_on_association(venue).klass
      ).to eq Venue
    end
  end

  context 'when no user is signed-in' do
    specify 'event should belong to guest user' do
      event = build :meetup_event
      expect(event.user_id).to eq User::GUEST.id
    end
  end

  context 'when input is ocruby event' do
    let(:event) { create :meetup_event, :ocruby_event }

    RSpecUtil::OCRUBY_EVENT.each do |attri, exp|
      describe attri do
        specify do
          expect(event.public_send(attri)).to eq exp
        end
      end
    end

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
