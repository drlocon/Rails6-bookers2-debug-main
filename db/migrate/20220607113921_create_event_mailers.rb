class CreateEventMailers < ActiveRecord::Migration[6.1]
  def change
    create_table :event_mailers do |t|

      t.timestamps
    end
  end
end
