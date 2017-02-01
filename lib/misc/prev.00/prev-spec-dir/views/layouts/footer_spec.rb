
describe 'footer' do
  let(:year) { DateTime.now.in_time_zone.year.to_s.freeze }

  [
    :root_path,
    :map_meetup_events_path,
    :new_user_registration_path
  ].each do |path|
    context "in #{path}" do
      before { visit public_send path }
      subject { page }

      it { should have_text '© Map My Meetups ' << year }
      it { should have_link 'About', href: '#' }
      it { should have_link 'Terms', href: '#' }
      it { should have_link 'Contact', href: '#' }
    end
  end
end
