
describe 'brand' do
  [
    :root_path,
    :map_meetup_events_path,
    :new_user_registration_path
  ].each do |path|
    context "in #{path}" do
      before { visit public_send path }
      subject { page }
      it { should have_link('Map My Meetups', href: root_path) }
    end
  end
end
