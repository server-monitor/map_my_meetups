
FactoryGirl.define do
  factory :geo_marker, aliases: [:location] do
    host      'hp.com'
    ip        '15.201.225.10'
    address   'Arastradero Preserve, Palo Alto, CA, USA'
    city      'Palo Alto'
    state     'CA'
    country   'US'
    latitude  37.3762
    longitude 122.1826

    user
    meetup_event
  end

  factory :user do
    name 'Tim Berners'
    data '...'

    sequence(:email, 1000) { |n| "tim#{n}@example.com" }

    password 'abcdefgh'
    password_confirmation 'abcdefgh'
  end

  factory :meetup_event do
    meetup_dot_com_id 231_280_691
    name              'Meetup Event Name'
    time              1_468_980_000_000
    utc_offset(-25_200_000)
    link              'http://www.meetup.com/LA-Software-Workshops/events/231280691/'

    venue_name        '8th Light'
    location          { create(:location) }

    user
  end
end
