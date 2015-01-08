class SelfEsteem < ActiveRecord::Base
  belongs_to :personal_datum

  validates :alcohol, :tabacco, :drugs, :walking_time_per_day, :jogging_time_per_day, :gym_workout_time_per_day, :wholesome_food_per_day, :junk_food_per_day, :weather, :season, :self_esteem, presence: true
  validates :tabacco, :drugs, :self_esteem, numericality: { only_integer: true }
  validates :alcohol, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
  validates :walking_time_per_day, :jogging_time_per_day, :gym_workout_time_per_day, :wholesome_food_per_day, :junk_food_per_day, numericality: { only_integer: true }
end
