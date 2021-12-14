class CreateLikes < ActiveRecord::Migration[6.1]
  def change
    create_table :likes do |t|
      t.references :user_id, null: false, foreign_key:{ to_table: :users }
      t.references :post_id, null: false, foreign_key:{ to_table: :posts }

      t.timestamps
    end
  end
end
