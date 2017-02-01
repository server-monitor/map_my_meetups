
require 'support/helpers/webmock'
require 'support/fixtures/get_list_of_params_for_model'

require 'support/constant'
include RSpecUtil

describe Meetup::GetListOfParamsForModel do
  it { should respond_to :error }
  it { should respond_to :error_set }
  it { should respond_to(:perform).with(1).argument }

  context 'when searching for only one event (using url)' do
    context 'when the same event url is entered more than once' do
      def append_slash(string)
        string.sub(%r{ /* \z}x, '/')
      end

      let(:event_unique_name) { 'SGVTech-events-233081385' }
      let(:host_and_path) do
        append_slash(WWW_MEETUP_DOT_COM) +
          append_slash(event_unique_name.gsub(/[-]/, '/'))
      end

      describe 'on the entry after the first, api services' do
        context 'when scheme is http' do
          let(:url) { 'http://' + host_and_path }

          before do
            setup_api_stub_request(
              url: url.sub(%r{http://}x, 'https://'),
              body: Fixture::GetListOfParamsForModel.res_body_of(
                event_unique_name
              ).to_json
            )

            pform = nil
            VCR.turned_off { pform = described_class.new.perform url }
            params = pform.list.first[:params]
            Meetup::CreateEvent.new.perform(params, User::GUEST.id)
            pform
          end

          it('should filter the new entry using the link key') do
            expect(MeetupEvent.count).to eq 1
          end

          it 'should not perform a request since the data ' \
             'is already in the database' do
            WebMock.reset!
            VCR.turned_off do
              described_class.new.perform url
            end
          end
        end

        context 'when scheme is https' do
          let(:url) { 'https://' + host_and_path }

          before do
            setup_api_stub_request(
              url: url.sub(%r{http://}x, 'https://'),
              body: Fixture::GetListOfParamsForModel.res_body_of(
                event_unique_name
              ).to_json
            )

            pform = nil
            VCR.turned_off { pform = described_class.new.perform url }
            params = pform.list.first[:params]
            Meetup::CreateEvent.new.perform(params, User::GUEST.id)
            pform
          end

          it('should filter the new entry using the link key') do
            expect(MeetupEvent.count).to eq 1
          end

          it 'should not perform a request since the data ' \
             'is already in the database' do
            WebMock.reset!
            VCR.turned_off { described_class.new.perform url }
          end
        end
      end
    end
  end
end
