class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.integer :user_id
      t.integer :client_id
      t.string :image_uid
      t.string :audio_uid
      t.integer :deleted

      t.timestamps
    end
  end
end
