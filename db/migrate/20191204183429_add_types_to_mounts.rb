class AddTypesToMounts < ActiveRecord::Migration[5.2]
  def change
    add_column :mounts, :type, :string
  end
end
