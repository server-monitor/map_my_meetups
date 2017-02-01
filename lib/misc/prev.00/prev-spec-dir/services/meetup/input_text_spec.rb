
require 'uri'
require 'rails_helper'

require 'support/constant'
include RSpecUtil

describe Meetup::InputText do
  shared_examples :error do |input_text:, msg: nil|
    describe '#error' do
      specify { expect(described_class.new(input_text).error).to eq msg }
    end
  end

  subject(:input_text) { described_class.new('dummy') }

  it { should respond_to :error }
  it { should respond_to :validated_uri? }
  it { should respond_to :event? }

  describe 'validation(s)' do
    context 'when input is ' << TEXT_WITH_SPACE do
      include_examples(
        :error,
        input_text: TEXT_WITH_SPACE,
        msg: 'Space is an invalid character (TODO)'
      )
    end
  end

  describe '#validated_uri?' do
    subject(:is_validated_uri) { input_text.validated_uri? }

    context 'when input is ' << TEXT_WITH_SPACE do
      specify do
        expect { described_class.new(TEXT_WITH_SPACE).validated_uri? }
          .to raise_error RuntimeError
      end
    end

    context 'when input is not meetup.com' do
      include_examples(
        :error,
        input_text: NOT_MEETUP_DOT_COM,
        msg: 'HTTP input host is not one of: ' << VALID_HOSTS_STRING
      )
    end

    context 'when input is ' << HTTP_MEETUP_DOT_COM do
      let(:input_text) { described_class.new HTTP_MEETUP_DOT_COM }
      it { should eq URI HTTP_MEETUP_DOT_COM }
      include_examples :error, input_text: HTTP_MEETUP_DOT_COM
    end

    context 'when input is ' << HTTPS_MEETUP_DOT_COM do
      let(:input_text) { described_class.new HTTPS_MEETUP_DOT_COM }
      it { should eq URI HTTPS_MEETUP_DOT_COM }
      include_examples :error, input_text: HTTPS_MEETUP_DOT_COM
    end

    FTP_MEETUP_DOT_COM = ('ftp://' << WWW_MEETUP_DOT_COM).freeze
    context 'when input is ' << FTP_MEETUP_DOT_COM do
      let(:input_text) { described_class.new FTP_MEETUP_DOT_COM }
      it { should be_falsy }
      include_examples :error, input_text: FTP_MEETUP_DOT_COM
    end

    context 'when input is ' << NOT_A_URL do
      let(:input_text) { described_class.new NOT_A_URL }
      it { should be_falsy }
      include_examples :error, input_text: NOT_A_URL
    end
  end

  describe '#event?' do
    subject(:event?) { input_text.event? }

    context 'when input is ' << TEXT_WITH_SPACE do
      specify do
        expect { described_class.new(TEXT_WITH_SPACE).event? }
          .to raise_error RuntimeError
      end
    end

    context 'when input is ' << OCRUBY_EVENT_URL do
      let(:input_text) { described_class.new OCRUBY_EVENT_URL }
      it { should eq OCRUBY_EVENT_URL_ID }
      include_examples :error, input_text: OCRUBY_EVENT_URL
    end

    context 'when input is ' << OCRUBY_GROUP_URL do
      let(:input_text) { described_class.new OCRUBY_GROUP_URL }
      it { should be_falsy }
      include_examples :error, input_text: OCRUBY_GROUP_URL
    end

    context 'when input is ' << NOT_MEETUP_DOT_COM do
      let(:input_text) { described_class.new NOT_MEETUP_DOT_COM }
      specify { expect { input_text.event? }.to raise_error RuntimeError }
    end

    context 'when input is ' << NOT_A_URL do
      let(:input_text) { described_class.new NOT_A_URL }
      specify { expect { input_text.event? }.to raise_error RuntimeError }
    end
  end
end
