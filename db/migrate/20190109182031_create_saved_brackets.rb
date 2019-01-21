class CreateSavedBrackets < ActiveRecord::Migration[5.2]
  def change
    create_table :saved_brackets do |t|
      t.string :name
      t.bigint :unique_game_number
      t.bigint :picked_games
      t.boolean :is_unique, default: false
      t.belongs_to :user, foreign_key: true, index: true

      t.timestamps
    end
  end
end
