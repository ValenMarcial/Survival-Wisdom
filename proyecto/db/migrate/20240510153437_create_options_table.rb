# frozen_string_literal: true

# Atributos de la Clase Options
class CreateOptionsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :options do |t|
      t.references :question, foreign_key: true
      t.string :description
      t.json :effects
    end
  end
end
