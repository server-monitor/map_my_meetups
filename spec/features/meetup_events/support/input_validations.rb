
def submit(input = nil)
  visit map_meetup_events_path

  list = input.is_a?(Array) ? input : [input]

  list.each do |url|
    fill_in RSpecUtil::MeetupFormID, with: url
    sleep 1
    click_on 'Submit'
    sleep 2
  end
end
