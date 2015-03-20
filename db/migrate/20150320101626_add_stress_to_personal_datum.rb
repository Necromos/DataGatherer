class AddStressToPersonalDatum < ActiveRecord::Migration
  def change
    add_column :personal_data, :stress, :boolean
  end
end
