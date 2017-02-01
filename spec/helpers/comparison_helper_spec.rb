
describe ComparisonHelper, order: :defined do
  describe '::url' do
    EVENTS_PATH = '/laruby/events'.freeze
    EVENTS_ID = '/232908101'.freeze
    PATH1 = (EVENTS_PATH + EVENTS_ID).freeze
    HOST = 'www.meetup.com'.freeze
    URL1 = (HOST + PATH1).freeze
    HTTPS = 'https://'.freeze
    HTTPS_URL1 = (HTTPS + URL1).freeze

    UP_TO_EVENTS = (HTTPS + HOST + EVENTS_PATH).freeze

    context 'when urls to be compared are not urls' do
      specify do
        expect do
          described_class.url('abcd', 'efgh')
        end.to raise_error RuntimeError
      end
    end

    [
      {
        title: 'are the same',
        params: [HTTPS_URL1, HTTPS_URL1],
        expected: :be_truthy
      },

      {
        title: 'differ in http schemes',
        params: [HTTPS_URL1, 'http://' << URL1],
        expected: :be_truthy
      },

      {
        title: 'differ in hosts',
        params: [HTTPS_URL1, 'https://meetup.com' << PATH1],
        expected: :be_falsy
      },

      {
        title: 'differ in paths',
        params: [UP_TO_EVENTS + EVENTS_ID, UP_TO_EVENTS + '/232908102'],
        expected: :be_falsy
      },

      {
        title: 'have the same paths but one path has trailing /',
        params: [HTTPS_URL1, HTTPS_URL1 + '/'],
        expected: :be_truthy
      }
    ].each do |title:, params:, expected:|
      context 'when urls to be compared ' << title do
        specify do
          expect(described_class.url(*params)).to public_send expected
        end
      end
    end
  end
end
