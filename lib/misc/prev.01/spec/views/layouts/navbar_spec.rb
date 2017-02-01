
describe 'nav bar' do
  [
    :root_path,
    :map_meetup_events_path,
    :new_user_registration_path
  ].each do |path|
    context "in #{path}" do
      before { visit public_send path }
      subject { page }

      it { should have_link 'Home', href: root_path }
      it { should have_link 'Meetups', href: map_meetup_events_path }
      it { should have_link 'sign up', href: new_user_registration_path }
      it { should have_link 'sign in', href: new_user_session_path }
    end
  end
end
