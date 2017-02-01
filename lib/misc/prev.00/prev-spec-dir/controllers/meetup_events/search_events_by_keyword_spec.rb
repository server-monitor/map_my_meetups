
describe MeetupEventsController do
  def post_create(search_input = '')
    process(
      :create,
      method: :post,
      params: { meetup_event: { search_input: search_input } },
      format: :js
    )
  end

  context 'when search_input is a keyword (not a URL)' do
    let(:post_create_valid_host) do
      VCR.use_cassette 'controllers/meetup_events/search_events_by_keyword' do
        # post_create 'ruby'
        post_create 'erlang' # No venue
      end
    end

    specify do
      post_create_valid_host
      pending
      raise
    end

    # it 'should change MeetupEvent count by 1' do
    #   expect { post_create_valid_host }
    #     .to change { MeetupEvent.count }.by(1)
    # end

    # describe 'redirect' do
    #   before { post_create_valid_host }
    #   it { should_not redirect_to root_path }
    # end
  end
end
