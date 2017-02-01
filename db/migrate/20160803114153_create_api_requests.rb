class CreateApiRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :api_requests do |t|
      t.string :url
      t.string :scheme
      t.string :host
      t.string :path
      t.string :query

      t.timestamps
    end
  end
end
