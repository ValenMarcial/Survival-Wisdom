# frozen_string_literal: true

## Atributos de la Clase Guide
class CreateGuidesTable < ActiveRecord::Migration[7.1]
  def change
    create_table :guides do |t|
      t.string :title
      t.string :rute_content
      t.references :skill, foreign_key: true

      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
