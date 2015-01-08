class CreatePersonalData < ActiveRecord::Migration
  def change
    create_table :personal_data do |t|
      t.integer :age
      t.string :nationality
      t.string :race
      t.string :living_country
      t.boolean :health_issues
      t.boolean :chronic_diseases
      t.boolean :smoker
      t.boolean :alcoholic
      t.boolean :druggy
      t.boolean :disabled

      t.timestamps
    end
  end
end
