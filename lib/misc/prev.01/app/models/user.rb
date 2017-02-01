class User < ApplicationRecord
  has_many :meetup_events

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # =+= guest user created at seed loading.
  #     This ugly hack exists to make db:[drop, create, reset, migrate] work
  begin
    if !ActiveRecord::Migration.check_pending! and !Rails.env.test?
      guest = User.find_by(email: 'guest@example.com')

      # raise 'TODO: fix me, User::GUEST not defined' if !guest
      GUEST = guest if guest
    end
  rescue ActiveRecord::NoDatabaseError, ActiveRecord::PendingMigrationError => e
    p rescued: [e.message, __FILE__]
  end

  def to_s
    name
  end
end
