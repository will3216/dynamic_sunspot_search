class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.references :post
      t.text :body

      t.timestamps null: false
    end
  end
end
