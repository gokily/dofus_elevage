class AddParentsToMounts < ActiveRecord::Migration[5.2]
  def change
    add_column :mounts, :father_id, :integer
    add_column :mounts, :mother_id, :integer
    add_column :mounts, :current_spouse_id, :integer
    add_index :mounts, :father_id
    add_index :mounts, :mother_id
    add_index :mounts, [:father_id, :mother_id]
  end
end
