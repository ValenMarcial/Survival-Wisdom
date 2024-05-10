class CreateQuestionsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :questions do |t|
      t.string :statement
      t.string :type
      
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end

