class AddPsychotropicToPersonalData < ActiveRecord::Migration
  def change
    add_column :personal_data, :psychotropic, :boolean
  end
end
