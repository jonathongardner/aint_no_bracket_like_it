class CreateUniqueBrackets < ActiveRecord::Migration[5.2]
  def change
    create_table :unique_brackets do |t|
      # use id as unique_game_number
      t.belongs_to :user, foreign_key: true, index: true

      t.timestamps
    end
  end
end
