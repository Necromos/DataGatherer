class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.integer :user_score
      t.belongs_to :self_esteem, index: true
      t.timestamps
    end
  end
end
