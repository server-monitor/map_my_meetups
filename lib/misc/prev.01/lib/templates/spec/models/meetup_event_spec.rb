
require 'rails_helper'

describe MeetupEvent do
  LOCATION = 'location'.freeze
  VALIDATED_ATTRIBUTES = %w[
    meetup_dot_com_id name time utc_offset link
  ].append(LOCATION).freeze

  describe 'validations' do
    let(:attr_value_inputs) do
      VALIDATED_ATTRIBUTES.reduce({}) do |memo, key|
        memo.merge(key => key.camelize)
      end.merge(
        'time' => 12.34, 'utc_offset' => -1234, LOCATION => GeoMarker.new
      )
    end

    VALIDATED_ATTRIBUTES.each do |field|
      describe "blank '#{field}' column" do
        let(:blank_value) { ['', '  ', " \n  \n  "][rand(1000) % 3] }
        specify do
          attr_value_inputs[field] = blank_value
          attr_value_inputs.delete field if field == LOCATION
          expect { MeetupEvent.create!(attr_value_inputs) }.to raise_exception(
            ActiveRecord::RecordInvalid, /#{field.humanize} can't be blank/
          )
        end
      end
    end
  end
end
