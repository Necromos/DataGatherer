class PersonalDatum < ActiveRecord::Base
  has_many :self_esteems

  validates :sex, :age, :nationality, :living_country, presence: true
  validates :age, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 120 }

  def to_array
    [self.age, self.nationality, self.living_country, self.health_issues, self.chronic_diseases, self.smoker, self.alcoholic, self.druggy, self.disabled, self.sex, self.psychotropic, self.stress]
  end
end
