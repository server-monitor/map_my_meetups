
# require 'rails_helper'

# th = ['Requested by', 'Host', 'IP', 'Address', 'Latitude', 'Longitude']
# table = 'table'

# describe table, type: :request,
#                 js: true,
#                 # js_vcr: true,
#                 # selenium_chrome: false,
#                 order: :defined do
#   before do
#     visit geo_markers_path
#     # VCR.use_cassette 'billy_test', record: :new_episodes do
#     #   visit geo_markers_path
#     # end
#   end

#   describe 'header' do
#     th.each_with_index do |column_title, ix|
#       specify do
#         within table do
#           expect(page)
#             .to have_css "th:nth-child(#{ix + 1})", text: column_title
#         end
#       end
#     end
#   end
# end

# # GUEST_USER_ESC = Regexp.escape('guest').freeze

# # IP_OCTAL_STR = '[0-2]? [[:digit:]]? [[:digit:]]'.freeze
# # IP_RE_STR = "(?:#{IP_OCTAL_STR}[.]){3} #{IP_OCTAL_STR}".freeze
# # ADDRESS_RE_STR = '[[:word:],\s]+'.freeze
# # ANY_RE_STR = '.*?'.freeze
# # COORDINATE_RE_STR = '\-?[[:digit:]]+[.][[:digit:]]+'.freeze

# # # IP address, street address, lat and long.
# # # '206.190.36.45'
# # # 'Bay Trail, Sunnyvale, CA 94089, USA',
# # # '37.4249',
# # # '-122.0074'

# # BIG_RE = "#{IP_RE_STR} #{ANY_RE_STR} " \
# #          "#{ADDRESS_RE_STR} #{ANY_RE_STR} " \
# #          "#{COORDINATE_RE_STR} #{ANY_RE_STR} " \
# #          "#{COORDINATE_RE_STR}".freeze

# # def build_expected_re(main_data)
# #   host_esc = Regexp.escape(main_data.fetch(:host))
# #   re_str = "#{GUEST_USER_ESC} #{ANY_RE_STR} " \
# #            "#{host_esc} #{ANY_RE_STR} #{BIG_RE}"

# #   return Regexp.new re_str, Regexp::EXTENDED | Regexp::MULTILINE
# # end

# # # describe 'fkme', order: :defined do
# # #   context 'no inputs', type: :request do
# # #     describe 'page', js: true, selenium_chrome: true do
# # #       before { visit map_geo_markers_path }
# # #       specify do
# # #         expect(page).to have_selector RSpecUtil::GOOGLE_PROVIDED_MAP_CLASS
# # #       end
# # #     end
# # #   end

# # #   describe 'billy', js: true, billy: true do
# # #     it 'should stub google' do
# # #       # proxy.stub('http://www.google.com/').and_return(text: "I'm not Google!")
# # #       # proxy.stub('http://www.google.com/').and_return(text: "I'm not Google!")
# # #       # visit 'https://www.google.com/'
# # #       # # save_and_open_page
# # #       # # expect(page).to have_content("I'm not Google!")
# # #       # expect(page).to have_content('Google')

# # #       VCR.use_cassette 'google' do
# # #         visit 'https://www.google.com/'
# # #         # save_and_open_page
# # #         expect(page).to have_content('Google')
# # #       end
# # #     end
# # #   end
# # # end

# # # # describe "GET /get_pull_requests", js: true do
# # # #   it "retreives student PRs for a repo when 'get prs' button is clicked" do
# # # #     test_seed
# # # #     cohort = Cohort.first
# # # #     lab = Lab.create(name: "Simple Math", repo:
# # # #      "https//github.com/learn-co-students/simple-math-web-
# # # #       0416", cohort: cohort)

# # # #     VCR.use_cassette('retreive_prs_feature_test') do
# # # #       visit cohort_lab_path(cohort, lab)
# # # #       click_link "get-prs-btn"
# # # #       sleep(10)
# # # #     end
# # # #     expect(lab.pull_requests.count).to eq(1)
# # # #   end
# # # # end
