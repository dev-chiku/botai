class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :uid
      t.string :input_text
      t.string :res_text
      t.string :res_status

      t.timestamps null: false
    end
  end
end
