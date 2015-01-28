class RemoveRaceFromPersonalData < ActiveRecord::Migration
  def change
    remove_column :personal_data, :race
  end
end
