module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :uuid

    def connect
      self.uuid = cookies[:user_uuid] || reject_unauthorized_connection
    end
  end
end
