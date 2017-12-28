class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts do |t|
      t.text :title
      t.text :body
      t.boolean :featured
      t.integer :blog_id
      t.integer :author_id
      t.float :average_rating
      t.datetime :published_at
      t.datetime :expired_at

      t.timestamps null: false
    end
  end
end
