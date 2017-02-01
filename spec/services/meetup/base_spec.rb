

describe Meetup::Base do
  context "when '#{described_class}' is included" do
    include Meetup::Base

    describe 'self' do
      subject { self }
      it { should respond_to :error }
      it { should respond_to :error_set }
    end

    SOME_ERROR = 'some error'.freeze
    context "when error_set('#{SOME_ERROR}')" do
      describe :error do
        specify do
          error_set SOME_ERROR
          expect(error).to eq SOME_ERROR
        end
      end
    end
  end
end
