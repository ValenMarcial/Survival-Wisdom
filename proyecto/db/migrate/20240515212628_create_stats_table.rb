# frozen_string_literal: true

# Atributos de la Clase Stats
class CreateStatsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :stats do |t|
      t.integer :days
      t.references :user, foreign_key: true
    end
  end
end
