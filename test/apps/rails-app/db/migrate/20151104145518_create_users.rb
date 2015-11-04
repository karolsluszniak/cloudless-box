class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.timestamps null: false
    end

    User.reset_column_information
    User.create!
  end
end
