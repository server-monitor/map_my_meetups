
require 'uri'
require 'support/helpers/webmock'

require 'support/fixtures/find_groups'
require 'support/fixtures/events'

describe Meetup::SearchEvents do
  let(:user_id) { User::GUEST.id }

  let(:dependency_find_groups_class) { Meetup::API::FindGroups }

  let(:text_to_search) { 'perl' }

  let(:stubbed_url) do
    Fixture::FindGroups.uri_for_find_groups_api_ep(text_to_search).to_s
  end

  it { should respond_to :error }
  it { should respond_to :error_set }
  it { should respond_to(:perform).with(2).arguments }
  it { should respond_to :result }

  shared_examples :error do |msg: nil|
    describe '#error' do
      specify do
        eq_or_match = (msg.is_a? Regexp) ? :match : :eq
        expect(subject.error).to public_send eq_or_match, msg
      end
    end
  end

  describe '#perform' do
    context 'when response is ok' do
      before do
        expected_events_uris.collect do |uri|
          url = uri.to_s
          setup_api_stub_request url: url,
                                 body: Fixture::Events.by_url(url).to_json
        end
      end

      let(:expected_events) do
        expected_events_uris.collect do |uri|
          event_data = nil
          VCR.turned_off do
            event_data = Meetup::API::GetEventData.new.perform(uri.to_s)
          end

          Meetup::CreateEvent.new.perform(event_data, user_id)
        end
      end

      let(:expected_groups) do
        Fixture::FindGroups.groups_found_using_search_term(text_to_search)
      end

      # # Still needed even though we're comparing the whole groups found array?
      # let(:expected_next_events) do
      #   expected_groups.select do |grp|
      #     grp['next_event']
      #   end
      # end

      let(:expected_events_uris) do
        expected_groups
          .select { |grp| grp['next_event'] }
          .collect do |grp|
            api_url = grp['link'].sub(%r{ http:// }x, 'https://')
                                 .sub(/www[.]/, 'api.')
            URI(URI.join(api_url, 'events/', grp['next_event']['id']))
          end
      end

      def perform_search(grps_with_next_event, user_id)
        described_class.new.perform grps_with_next_event, user_id
      end

      let(:groups) do
        setup_api_stub_request body: expected_groups.to_json
        grps = nil
        VCR.turned_off do
          grps = dependency_find_groups_class.new.perform text_to_search
        end
        grps
      end

      let(:groups_with_next_event) { groups.with_next_event }

      let(:search_events) do
        perform_search groups_with_next_event, user_id
      end

      describe '#result' do
        subject(:result) { search_events.result }
        it { should respond_to :events }

        # # Move to private later?
        # it { should respond_to :from_api }

        describe '#events' do
          describe 'event names' do
            specify do
              expect(subject.events.map(&:name))
                .to eq expected_events.as_json.map { |ev| ev['name'] }
            end
          end

          context 'when event exists' do
            it 'should not be entered into the database' do
              perform_search groups_with_next_event, user_id
              perform_search groups_with_next_event, user_id
              expect(MeetupEvent.count).to eq expected_events.count
            end
          end
        end
      end

      include_examples :error
    end
  end

  # let(:search_input) { 'https://www.meetup.com/SGVTech/events/232979651/' }
  # let(:user_id) { User::GUEST.id }
  # let(:user_uuid) { 'user_' << user_id.to_s + '_' << SecureRandom.uuid.to_s }
  # let(:ids_in_cookie_jar) { [] }
  # let(:params) { [search_input, user_id, user_uuid, *ids_in_cookie_jar] }

  # describe 'queue' do
  #   specify do
  #     ActiveJob::Base.queue_adapter = :test
  #     expect { ApiRequestJob.perform_later(*params) }
  #       .to have_enqueued_job.with(*params)
  #   end
  # end

  # context 'when job is performed' do
  #   let(:job) { described_class.perform_later(*params) }

  #   before do
  #     VCR.use_cassette 'jobs/main' do
  #       meetup_event = MeetupEvent.new
  #       meetup_event.search_input = search_input
  #       meetup_event.user_id = user_id
  #       meetup_event.save!
  #     end
  #   end

  #   context 'when event already exists' do
  #     describe 'MeetupEvent count' do
  #       specify do
  #         expect do
  #           VCR.use_cassette 'jobs/perform_jobs_event_exists' do
  #             perform_enqueued_jobs { job }
  #           end
  #         end.not_to change(MeetupEvent, :count)
  #       end
  #     end
  #   end

  #   context 'when event does not exist' do
  #     describe 'MeetupEvent count' do
  #       let(:job) do
  #         described_class.perform_later(
  #           'https://www.meetup.com/Learn-JavaScript/events/232866049/',
  #           *params[1..-1]
  #         )
  #       end

  #       specify do
  #         expect do
  #           VCR.use_cassette 'jobs/perform_jobs_event_does_not_exist' do
  #             perform_enqueued_jobs { job }
  #           end
  #         end.to change(MeetupEvent, :count).by 1
  #       end
  #     end
  #   end
  # end
end
