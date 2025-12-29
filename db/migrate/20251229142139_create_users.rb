class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email_address, null: false, index: { unique: true }
      t.datetime :email_verified
      t.string :new_email
      t.string :email_verification_token
      t.datetime :email_verification_token_created_at
      t.string :username, null: false, index: { unique: true }
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :bio
      t.string :password_digest
      t.string :reset_password_token
      t.datetime :reset_password_token_created_at

      t.timestamps
    end
  end
end
