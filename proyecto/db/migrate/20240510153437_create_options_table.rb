class CreateOptionsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :options do |t|
      t.references :question, foreign_key: true
      t.string :description
      t.json :effects

      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
