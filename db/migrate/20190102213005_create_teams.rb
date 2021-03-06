class CreateTeams < ActiveRecord::Migration[5.2]
  def change
    create_table :teams do |t|
      t.string :name, index: true
      t.string :short_name, index: true, length: 16
      t.string :city
      t.string :state

      t.timestamps
    end
  end
end
