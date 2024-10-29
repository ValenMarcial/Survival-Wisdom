# frozen_string_literal: true

# Atributos de la Clase Question
class CreateQuestionsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :questions do |t|
      t.string :statement
      t.string :typeCard
      t.integer :leftclicks, default: 0
      t.integer :rightclicks, default: 0
    end
  end
end
