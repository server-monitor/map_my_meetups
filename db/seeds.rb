DEFAULT_PW = 'abcdefgh'.freeze if !defined? DEFAULT_PW

User.find_or_create_by!(email: 'guest@example.com') do |user|
  user.name = 'guest'
  user.password = DEFAULT_PW
  user.password_confirmation = DEFAULT_PW
end
