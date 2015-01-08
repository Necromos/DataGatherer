class CreateSelfEsteems < ActiveRecord::Migration
  def change
    create_table :self_esteems do |t|
      t.integer :personal_datum_id
      t.integer :alcohol
      t.integer :tabacco
      t.integer :drugs
      t.integer :walking_time_per_day
      t.integer :jogging_time_per_day
      t.integer :gym_workout_time_per_day
      t.integer :swimming_time_per_day
      t.integer :wholesome_food_per_day
      t.integer :junk_food_per_day
      t.string :weather
      t.string :season
      t.integer :self_esteem

      t.timestamps
    end
  end
end
