class CreateUniqueBrackets < ActiveRecord::Migration[5.2]
  def change
    create_table :unique_brackets do |t|
      # use id as unique_game_number
      # This table is only for quick look ups, this will contain every possible
      # bracket and if it has been taken it will be linked to the user who submits it
      t.belongs_to :user, foreign_key: true, index: true

      t.timestamps
    end
  end
end
