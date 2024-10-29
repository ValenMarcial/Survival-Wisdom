# frozen_string_literal: true

# Atributos de la Clase Skill
class CreateSkillsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :skills do |t|
      t.string :name
      t.string :description
      t.string :dificulty

      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
