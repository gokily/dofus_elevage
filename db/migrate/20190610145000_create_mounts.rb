class CreateMounts < ActiveRecord::Migration[5.2]
  def change
    create_table :mounts do |t|
      t.string :name
      t.references :user, foreign_key: true
      t.string :color
      t.integer :reproduction
      t.string :sex
      t.boolean :pregnant

      t.timestamps
    end
    add_index :mounts, [:user_id, :created_at]
  end
end
