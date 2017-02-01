
describe 'Background job service' do
  pending '...'
end
# RSpec.describe ApiRequestJob, type: :job do
#   include ActiveJob::TestHelper

#   let(:search_input) { 'https://www.meetup.com/SGVTech/events/232979651/' }
#   let(:user_id) { User::GUEST.id }
#   let(:user_uuid) { 'user_' << user_id.to_s + '_' << SecureRandom.uuid.to_s }
#   let(:ids_in_cookie_jar) { [] }
#   let(:params) { [search_input, user_id, user_uuid, *ids_in_cookie_jar] }

#   describe 'queue' do
#     specify do
#       ActiveJob::Base.queue_adapter = :test
#       expect { ApiRequestJob.perform_later(*params) }
#         .to have_enqueued_job.with(*params)
#     end
#   end

#   context 'when job is performed' do
#     let(:job) { described_class.perform_later(*params) }

#     before do
#       VCR.use_cassette 'jobs/main' do
#         meetup_event = MeetupEvent.new
#         meetup_event.search_input = search_input
#         meetup_event.user_id = user_id
#         meetup_event.save!
#       end
#     end

#     context 'when event already exists' do
#       describe 'MeetupEvent count' do
#         specify do
#           expect do
#             VCR.use_cassette 'jobs/perform_jobs_event_exists' do
#               perform_enqueued_jobs { job }
#             end
#           end.not_to change(MeetupEvent, :count)
#         end
#       end
#     end

#     context 'when event does not exist' do
#       describe 'MeetupEvent count' do
#         let(:job) do
#           described_class.perform_later(
#             'https://www.meetup.com/Learn-JavaScript/events/232866049/',
#             *params[1..-1]
#           )
#         end

#         specify do
#           expect do
#             VCR.use_cassette 'jobs/perform_jobs_event_does_not_exist' do
#               perform_enqueued_jobs { job }
#             end
#           end.to change(MeetupEvent, :count).by 1
#         end
#       end
#     end
#   end
# end
