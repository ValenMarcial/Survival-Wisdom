# frozen_string_literal: true

# Atributos de la Clase Bar
class CreateBarsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :bars do |t|
      t.string :name_bar
      t.integer :value

      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
