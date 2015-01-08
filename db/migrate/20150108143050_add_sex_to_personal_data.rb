class AddSexToPersonalData < ActiveRecord::Migration
  def change
    add_column :personal_data, :sex, :string
  end
end
