
require 'support/helpers/webmock'

require 'support/fixtures/find_groups'

describe Meetup::API::FindGroups do
  let(:text_to_search) { 'dummy' }
  let(:stubbed_url) do
    Fixture::FindGroups.uri_for_find_groups_api_ep(text_to_search).to_s
  end

  it { should respond_to :error }
  it { should respond_to :error_set }
  it { should respond_to(:perform).with(1).argument }
  it { should respond_to :data }
  it { should respond_to :with_next_event }

  shared_examples :error do |msg: nil|
    describe '#error' do
      specify do
        eq_or_match = (msg.is_a? Regexp) ? :match : :eq
        expect(subject.error).to public_send eq_or_match, msg
      end
    end
  end

  describe '#perform' do
    context 'when response is not ok' do
      subject(:groups) do
        setup_api_stub_request status: 400
        grps = nil
        VCR.turned_off { grps = described_class.new.perform text_to_search }
        grps
      end

      include_examples :error, msg: /Response .+? is \s+ not \s+ Net::HTTPOK/x
    end

    context 'when response is ok' do
      let(:expected_groups) do
        Fixture::FindGroups.groups_found_using_search_term(text_to_search)
      end

      context 'when res body is blank' do
        subject(:groups) do
          setup_api_stub_request
          grps = nil
          VCR.turned_off { grps = described_class.new.perform text_to_search }
          grps
        end

        include_examples :error, msg: 'Response body is blank'
      end

      subject(:groups) do
        setup_api_stub_request body: expected_groups.to_json
        grps = nil
        VCR.turned_off { grps = described_class.new.perform text_to_search }
        grps
      end

      describe '#data' do
        specify { expect(groups.data).to eq expected_groups }
      end

      describe '#with_next_event' do
        let(:expected_next_events) do
          expected_groups.select { |grp| grp['next_event'] }
        end

        specify { expect(groups.with_next_event).to eq expected_next_events }
      end

      include_examples :error
    end
  end
end
