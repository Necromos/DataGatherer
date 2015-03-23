# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
FunnyStuff.delete_all
source_path = Rails.root.join('app','assets','images')
Dir.foreach(source_path).each do |image|
  FunnyStuff.create(name: image, source: 'http://4chan.org')
end
