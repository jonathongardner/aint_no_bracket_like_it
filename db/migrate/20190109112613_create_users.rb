class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email, index: true, unique: true
      t.string :username, index: true, unique: true

      # database_authentication
      t.string :password_digest

      t.string :password_reset_token_digest
      t.integer :password_reset_token_attempts

      # t.string :email_confirmation_digest

      t.boolean :approved, default: false, null: false

      t.boolean :admin, default: false, null: false

      t.timestamps
    end
  end
end
