
require_relative './constant'

FactoryGirl.define do
  factory :user do
    sequence(:name)         { |n| "user#{n}" }
    data                    '...'
    email                   { "#{name}@example.com" }
    password                'abcdefgh'
    password_confirmation   'abcdefgh'

    # trait :with_meetup_events do
    #   transient { count 1 }

    #   after(:create) do |user, evaluator|
    #     create_list(:meetup_event, evaluator.count, user: user)
    #   end
    # end
  end

  factory :meetup_event do
    user { User::GUEST }

    trait :ocruby_event do
      after :build do |event|
        RSpecUtil::OCRUBY_EVENT.each do |attri, val|
          event.public_send attri.to_s << '=', val
        end

        event.venue = create(:venue, :ocruby_event, meetup_event: event)
      end
    end
  end

  factory :venue do
    trait :ocruby_event do
      after :build do |venue|
        RSpecUtil::OCRUBY_EVENT_VENUE.each do |attri, val|
          venue.public_send attri.to_s << '=', val
        end
      end
    end

    meetup_event
  end
end
