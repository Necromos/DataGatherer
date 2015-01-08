class SelfEsteem < ActiveRecord::Base
  belongs_to :personal_datum

  validates :alcohol, :tabacco, :drugs, :walking_time_per_day, :jogging_time_per_day, :gym_workout_time_per_day, :wholesome_food_per_day, :junk_food_per_day, :weather, :season, :self_esteem, presence: true
end
