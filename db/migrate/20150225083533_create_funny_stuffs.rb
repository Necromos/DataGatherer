class CreateFunnyStuffs < ActiveRecord::Migration
  def change
    create_table :funny_stuffs do |t|
      t.string :name
      t.string :source
      t.timestamps
    end
  end
end
