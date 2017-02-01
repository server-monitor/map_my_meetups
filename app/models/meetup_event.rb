
class MeetupEvent < ApplicationRecord
  belongs_to :user
  has_one :venue
  validates_presence_of :venue

  before_validation :assign_user

  private

  def assign_user
    # I don't know why User::GUEST NameError in prod.
    self.user_id = user ? user.id : User.find_by!(email: 'guest@example.com').id
    # self.user_id = user ? user.id : User::GUEST.id
  end
end
