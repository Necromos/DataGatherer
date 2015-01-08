class PersonalDatum < ActiveRecord::Base
  has_many :self_esteems

  validates :sex, :age, :nationality, :race, :living_country, presence: true
  validates :age, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 120 }
end
